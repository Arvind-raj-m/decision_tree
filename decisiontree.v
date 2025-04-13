module decisiontree (
    input clk,
    input reset,
    input [15:0] study_hours,       // Study_Hours_per_Week (0-39)
    input [15:0] attendance,        // Attendance_Rate (50.13-99.88) scaled to 0-9999
    input [15:0] past_scores,       // Past_Exam_Scores (50-100)
    input [1:0] parental_edu,       // Parental_Education_Level encoded:
                                    // 00: High School, 01: Bachelors, 10: Masters, 11: PhD
    input internet_access,          // Internet_Access_at_Home (0: No, 1: Yes)
    input extracurricular,          // Extracurricular_Activities (0: No, 1: Yes)
    output reg pass_fail,           // 0: Fail, 1: Pass
    output reg decision_valid       // High when output is valid
);

// Fixed-point representation parameters
localparam FP_INT = 8;       // Integer bits
localparam FP_FRAC = 8;      // Fractional bits

// Decision tree thresholds (extracted from dataset analysis)
localparam TH_STUDY_HOURS = 16'd25;          // 25 hours
localparam TH_ATTENDANCE = 16'd7500;         // 75.00% (scaled)
localparam TH_PAST_SCORES = 16'd75;          // 75 score
localparam TH_ATTENDANCE_LEAF = 16'd8500;    // 85.00% (scaled)

// Pipeline registers
reg [15:0] study_hours_reg;
reg [15:0] attendance_reg;
reg [15:0] past_scores_reg;
reg [1:0] parental_edu_reg;
reg internet_access_reg;
reg extracurricular_reg;

reg [2:0] pipeline_stage;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        study_hours_reg <= 0;
        attendance_reg <= 0;
        past_scores_reg <= 0;
        parental_edu_reg <= 0;
        internet_access_reg <= 0;
        extracurricular_reg <= 0;
        pipeline_stage <= 0;
        pass_fail <= 0;
        decision_valid <= 0;
    end else begin
        // Pipeline stage 0: Register inputs
        if (pipeline_stage == 0) begin
            study_hours_reg <= study_hours;
            attendance_reg <= attendance;
            past_scores_reg <= past_scores;
            parental_edu_reg <= parental_edu;
            internet_access_reg <= internet_access;
            extracurricular_reg <= extracurricular;
            pipeline_stage <= 1;
            decision_valid <= 0;
        end 
        // Pipeline stage 1: First level decision (Study Hours)
        else if (pipeline_stage == 1) begin
            if (study_hours_reg >= TH_STUDY_HOURS) begin
                // Right branch: Study Hours >= 25
                pipeline_stage <= 2;
            end else begin
                // Left branch: Study Hours < 25
                pipeline_stage <= 3;
            end
        end
        // Pipeline stage 2: Right branch evaluation (Study Hours >= 25)
        else if (pipeline_stage == 2) begin
            if (attendance_reg >= TH_ATTENDANCE_LEAF) begin
                // Pass if attendance >= 85%
                pass_fail <= 1;
                decision_valid <= 1;
                pipeline_stage <= 0;
            end else begin
                // Check past scores
                if (past_scores_reg >= TH_PAST_SCORES) begin
                    pass_fail <= 1;
                end else begin
                    pass_fail <= 0;
                end
                decision_valid <= 1;
                pipeline_stage <= 0;
            end
        end
        // Pipeline stage 3: Left branch evaluation (Study Hours < 25)
        else if (pipeline_stage == 3) begin
            if (attendance_reg >= TH_ATTENDANCE) begin
                // Check parental education
                if (parental_edu_reg >= 2'b10) begin // Masters or PhD
                    pass_fail <= 1;
                end else begin
                    pass_fail <= 0;
                end
            end else begin
                // Check internet access
                if (internet_access_reg && extracurricular_reg) begin
                    pass_fail <= 1;
                end else begin
                    pass_fail <= 0;
                end
            end
            decision_valid <= 1;
            pipeline_stage <= 0;
        end
    end
end

endmodule


/*module decisiontree (
    input [2:0] category,    // 0:Electronics, 1:Clothing, 2:Footwear, 3:Books, 4:Home Appliances
    input [9:0] price,       // Actual price value
    input [2:0] payment,     // 0:Credit Card, 1:Debit Card, 2:PayPal, 3:Amazon Pay, 4:Gift Card
    input [3:0] quantity,    // Order quantity
    input [3:0] location,    // 0:New York, 1:San Francisco, etc.
    output reg [1:0] status  // 0:Cancelled, 1:Completed, 2:Pending
);

always @(*) begin
    case(category)
        3'd0: begin // Electronics
            if (price > 300) begin
                case(payment)
                    2: status = 2'b01; // PayPal -> Completed
                    0: status = 2'b10; // Credit Card -> Pending
                    default: status = 2'b00; // Others -> Cancelled
                endcase
            end else begin
                if ((quantity > 2) && (location == 0 || location == 1)) begin
                    status = 2'b01; // Completed
                end else if (quantity <= 1) begin
                    status = 2'b00; // Cancelled
                end else begin
                    status = 2'b10; // Pending
                end
            end
        end
        3'd1: begin // Clothing
            case(payment)
                2: status = 2'b01; // PayPal -> Completed
                3: status = 2'b10; // Amazon Pay -> Pending
                default: status = 2'b00; // Others -> Cancelled
            endcase
        end
        3'd4: begin // Home Appliances
            if (price > 1000) begin
                status = 2'b00; // Cancelled
            end else begin
                status = (payment == 4) ? 2'b10 : 2'b01; // Gift Card->Pending, else->Completed
            end
        end
        default: begin // Footwear, Books, others
            status = 2'b10; // Default to Pending
        end
    endcase
end

endmodule*/