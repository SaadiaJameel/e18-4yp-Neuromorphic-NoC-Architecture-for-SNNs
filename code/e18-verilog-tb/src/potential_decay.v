`timescale 1ns/100ps
//Potential decay for divinding by 1, 2, 4, and 8 only

module potential_decay(
    input wire CLK,                             //input clock
    input wire clear,                           //clear signal to define timesteps
    input wire[11:0] neuron_address_initialization,            //neuron address
    input wire[3:0] decay_rate,                 //input decay rate,
    input wire[31:0] membrane_potential_initialization,        // membrane_potential
    output reg[31:0] output_potential_decay     //output of the new potential value after decay
    );   
    
    reg [1:0] sign;                         //sign of the potential value
    reg [7:0] exponent;                     //get exponent of membrane potential value 
    reg [22:0] mantissa;                    //get mantissa from membrane potential value
    reg [7:0] adjusted_exponent;            //variable to assign new exponent value
    reg[7:0] exponent_divided_by_2;         //store division by 2
    reg[7:0] exponent_divided_by_4;         //store division by 4
    wire Exception;                         //exception of the addition 
    wire [31:0] result_divide_by_2_plus_4;  //variable to assign new exponent value
    reg[31:0] number_divided_by_2;          //register to store divided number 2
    reg[31:0] number_divided_by_4;          //register to store divided number 4
    reg[11:0] neuron_address;               //neruon address
    reg[31:0] membrane_potential;           //memebrane potential
    
    //addition module instantiate
    Addition_Subtraction Addition_Subtraction_1(number_divided_by_2, number_divided_by_4, 1'b0, Exception, result_divide_by_2_plus_4);
    
    //initialize membrane potential value and sneuron address
    always @(membrane_potential_initialization, neuron_address_initialization) begin
        neuron_address = neuron_address_initialization;
        membrane_potential = membrane_potential_initialization;
    end

    //clear signal initiate
    always @(clear) begin

        if(clear==1) begin
            sign = membrane_potential[31];     
            exponent = membrane_potential[30:23];    
            mantissa = membrane_potential[22:0]; 
            
            case (decay_rate)

                4'b0001: begin         //divide by 1
                    adjusted_exponent = exponent;
                    output_potential_decay = {sign, adjusted_exponent, mantissa};
                end

                4'b0010: begin         //divide by 2
                    adjusted_exponent = exponent-8'd1;
                    output_potential_decay = {sign, adjusted_exponent, mantissa};
                end

                4'b0100: begin         //divide by 4
                    adjusted_exponent = exponent-8'd2;
                    output_potential_decay = {sign, adjusted_exponent, mantissa};
                end

                4'b1000: begin         //divide by 8
                    adjusted_exponent = exponent-8'd3;
                    output_potential_decay = {sign, adjusted_exponent, mantissa};
                end

                4'b0011: begin         //add division by 2 and 4
                    exponent_divided_by_2 = exponent-8'd1;
                    exponent_divided_by_4 = exponent-8'd2;
                    number_divided_by_2 = {sign, exponent_divided_by_2, mantissa};
                    number_divided_by_4 = {sign, exponent_divided_by_4, mantissa};
                    output_potential_decay = result_divide_by_2_plus_4;
                end

                default: begin
                    adjusted_exponent = exponent;
                    output_potential_decay = {sign, adjusted_exponent, mantissa};
                end
        endcase

        membrane_potential = output_potential_decay;
        end
    end

endmodule