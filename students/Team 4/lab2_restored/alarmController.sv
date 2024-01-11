module alarmController (
    input [8:0] total_time, // total starting time (seconds)
    input start, 
    input reset, 
    input clock, // input clock (100 Hz or 200 Hz)
    output reg [19:0] time_remaining, // time remaining in centiseconds
    output reg buzzer_on, // buzzer output
    output reg display_flash // display flash
    );

    reg [1:0] start_sr;
    reg [1:0] reset_sr;
    reg [1:0] currentState; // SET, RUN, PAUSE, BEEP
    reg [1:0] nextState;
    reg [19:0] time_remaining_d;

    always @(posedge clock) begin
        // start_sr <= {start_sr[0], start};
        // reset_sr <= {reset_sr[0], reset};
        // currentState <= nextState;
        time_remaining <= time_remaining + 20'd1;
		  // posedge: 0->0, 1+5, 2+6, 3+18, 4+12, 5+25, 6+18, 7+42, 8+24
		  // negedge:       1+1+4, 
    end

    // localparam STATE_SET = 2'b00;
    // localparam STATE_RUN = 2'b01;
    // localparam STATE_PAUSE = 2'b10;
    // localparam STATE_BEEP = 2'b11;

    // always_comb begin
    //     case (currentState)
    //         STATE_SET: begin
    //             if (start_sr == 2'b10) begin
    //                 nextState = STATE_RUN;
    //                 // time_remaining_d = time_remaining;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else begin
    //                 nextState = STATE_SET;
	// 				    //  time_remaining_d = total_time * 19'd100;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
	// 			    end	  
    //         end

    //         STATE_RUN: begin
    //             if (start_sr == 2'b10) begin
    //                 nextState = STATE_PAUSE;
    //                 // time_remaining_d = time_remaining;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else if (reset_sr == 2'b10) begin
    //                 nextState = STATE_SET;
    //                 // time_remaining_d = total_time * 19'd100;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else if (time_remaining <= 'd0) begin
    //                 nextState = STATE_BEEP;
    //                 // time_remaining_d = 0;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else begin
    //                 nextState = STATE_RUN;
    //                 // time_remaining_d = time_remaining - 'd1;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end  
    //         end

    //         STATE_PAUSE: begin
    //             if (start_sr == 2'b10) begin
    //                 nextState = STATE_RUN;
    //                 // time_remaining_d = time_remaining;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else if (reset_sr == 2'b10) begin
    //                 nextState = STATE_SET;
    //                 // time_remaining_d = total_time * 19'd100;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else begin
    //                 nextState = STATE_PAUSE;
    //                 // time_remaining_d = time_remaining;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end
    //         end

    //         STATE_BEEP: begin
    //             if (reset_sr == 2'b10) begin
    //                 nextState = STATE_SET;
    //                 // time_remaining_d = total_time * 19'd100;
    //                 buzzer_on = 'b0;
    //                 display_flash = 'b0;
    //             end else begin
    //                 nextState = STATE_BEEP;
    //                 // time_remaining_d = time_remaining;
    //                 buzzer_on = 'b1;
    //                 display_flash = 'b1;
    //             end
    //         end

    //         default: begin
	// 				nextState = STATE_SET;
	// 				// time_remaining_d = total_time * 19'd100;
	// 				buzzer_on = 'b0;
	// 				display_flash = 'b0;
    //         end
				
    //     endcase 
    // end

    initial begin
        start_sr = 2'b11;
        reset_sr = 2'b11;
        currentState = 2'b00;
        nextState = 2'b00;
        time_remaining = 'd0;
	end
	 
	 
endmodule