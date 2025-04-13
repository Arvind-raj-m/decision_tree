module decisiontree_tb;

reg clk;
reg reset;
reg [15:0] study_hours;
reg [15:0] attendance;
reg [15:0] past_scores;
reg [1:0] parental_edu;
reg internet_access;
reg extracurricular;
wire pass_fail;
wire decision_valid;

// Instantiate the DUT
decisiontree dut (
    .clk(clk),
    .reset(reset),
    .study_hours(study_hours),
    .attendance(attendance),
    .past_scores(past_scores),
    .parental_edu(parental_edu),
    .internet_access(internet_access),
    .extracurricular(extracurricular),
    .pass_fail(pass_fail),
    .decision_valid(decision_valid)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test cases
initial begin
    // Initialize inputs
    reset = 1;
    study_hours = 0;
    attendance = 0;
    past_scores = 0;
    parental_edu = 0;
    internet_access = 0;
    extracurricular = 0;
    
    // Reset the design
    #10 reset = 0;
    
    // Test case 1: High performance student (should pass)
    // S147,Male,31,68.26784098370288,86,High School,Yes,Yes,63,Pass
    #10 study_hours = 31;
    attendance = 6826; // 68.27% scaled to 0-9999
    past_scores = 86;
    parental_edu = 2'b00; // High School
    internet_access = 1;
    extracurricular = 1;
    
    #30; // Wait for 3 clock cycles (pipeline depth)
    
    if (pass_fail !== 1'b1 || decision_valid !== 1'b1) begin
        $display("Test case 1 failed: Expected Pass, got %s", pass_fail ? "Pass" : "Fail");
    end else begin
        $display("Test case 1 passed");
    end
    
    // Test case 2: Low performance student (should fail)
    // S136,Male,16,78.22292712613206,73,PhD,No,No,50,Fail
    #10 study_hours = 16;
    attendance = 7822; // 78.22%
    past_scores = 73;
    parental_edu = 2'b11; // PhD
    internet_access = 0;
    extracurricular = 0;
    
    #30;
    
    if (pass_fail !== 1'b0 || decision_valid !== 1'b1) begin
        $display("Test case 2 failed: Expected Fail, got %s", pass_fail ? "Pass" : "Fail");
    end else begin
        $display("Test case 2 passed");
    end
    
    // Test case 3: Borderline case (should pass)
    // S209,Female,21,87.52509623826568,74,PhD,Yes,No,55,Fail
    #10 study_hours = 21;
    attendance = 8752; // 87.52%
    past_scores = 74;
    parental_edu = 2'b11; // PhD
    internet_access = 1;
    extracurricular = 0;
    
    #30;
    
    if (pass_fail !== 1'b0 || decision_valid !== 1'b1) begin
        $display("Test case 3 failed: Expected Fail, got %s", pass_fail ? "Pass" : "Fail");
    end else begin
        $display("Test case 3 passed");
    end
    
    // Test case 4: High attendance but low study hours (should pass with Masters/PhD)
    // S078,Female,37,98.65551746350522,63,Masters,No,Yes,70,Pass
    #10 study_hours = 37;
    attendance = 9865; // 98.66%
    past_scores = 63;
    parental_edu = 2'b10; // Masters
    internet_access = 0;
    extracurricular = 1;
    
    #30;
    
    if (pass_fail !== 1'b1 || decision_valid !== 1'b1) begin
        $display("Test case 4 failed: Expected Pass, got %s", pass_fail ? "Pass" : "Fail");
    end else begin
        $display("Test case 4 passed");
    end
    
    // Test case 5: Low study hours but with internet and extracurricular (should pass)
    // S112,Male,14,84.35827527016656,94,High School,Yes,Yes,59,Fail
    #10 study_hours = 14;
    attendance = 8435; // 84.36%
    past_scores = 94;
    parental_edu = 2'b00; // High School
    internet_access = 1;
    extracurricular = 1;
    
    #30;
    
    if (pass_fail !== 1'b1 || decision_valid !== 1'b1) begin
        $display("Test case 5 failed: Expected Pass, got %s", pass_fail ? "Pass" : "Fail");
    end else begin
        $display("Test case 5 passed");
    end
    
    // End simulation
    #10 $finish;
end

endmodule

/*module decisiontree_tb;

    // Inputs
    reg [2:0] category;
    reg [9:0] price;
    reg [2:0] payment;
    reg [3:0] quantity;
    reg [3:0] location;
    
    // Outputs
    wire [1:0] status;
    
    // Instantiate UUT
    decisiontree uut (
        .category(category),
        .price(price),
        .payment(payment),
        .quantity(quantity),
        .location(location),
        .status(status)
    );
    
    initial begin
        // Test Case 1: High-price electronics with PayPal (should complete)
        category = 0; price = 500; payment = 2; quantity = 1; location = 0;
        #10 $display("Test 1: Cat=Electronics, $500, PayPal => Status=%b (Expected 01-Complete)", status);
        
        // Test Case 2: Low-price electronics, high quantity in NY (should complete)
        category = 0; price = 100; payment = 1; quantity = 3; location = 0;
        #10 $display("Test 2: Cat=Electronics, $100, 3qty NY => Status=%b (Expected 01-Complete)", status);
        
        // Test Case 3: Clothing with Amazon Pay (should pending)
        category = 1; price = 20; payment = 3; quantity = 2; location = 5;
        #10 $display("Test 3: Cat=Clothing, Amazon Pay => Status=%b (Expected 10-Pending)", status);
        
        // Test Case 4: Home Appliances >$1000 (should cancel)
        category = 4; price = 1200; payment = 0; quantity = 1; location = 3;
        #10 $display("Test 4: Cat=HomeAppl, $1200 => Status=%b (Expected 00-Cancelled)", status);
        
        // Test Case 5: Books (default pending)
        category = 3; price = 15; payment = 1; quantity = 1; location = 2;
        #10 $display("Test 5: Cat=Books => Status=%b (Expected 10-Pending)", status);
        
        #10 $finish;
    end
    
endmodule*/