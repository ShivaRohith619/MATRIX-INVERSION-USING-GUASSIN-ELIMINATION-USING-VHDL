library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use work.MatrixPackage.all;

entity MatrixInversion_tb is
end MatrixInversion_tb;

architecture behavior of MatrixInversion_tb is

    -- Signals for the DUT
    signal clk    : STD_LOGIC := '0';
    signal reset  : STD_LOGIC := '0';
    signal start  : STD_LOGIC := '0';
    signal A      : MATRIX;
    signal inv_A  : MATRIX;
    signal idone  : STD_LOGIC;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.MatrixInversion
        port map (
            clk    => clk,
            reset  => reset,
            start  => start,
            A      => A,
            inv_A  => inv_A,
            idone  => idone
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize
        wait for 20 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Apply test matrix
        A(0,0) <= 1.0;  A(0,1) <= 24.0;  A(0,2) <= 3.0;
        A(1,0) <= 4.0;  A(1,1) <= 6.0;  A(1,2) <= 8.0;
        A(2,0) <= 72.0;  A(2,1) <= 1.0;  A(2,2) <= 1.0;

        wait for 10 ns;
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Wait until inversion is done
        wait until idone = '1';

        -- Report result
        for i in 0 to 2 loop
            for j in 0 to 2 loop
                report "inv_A(" & integer'image(i) & "," & integer'image(j) & ") = " & real'image(inv_A(i,j));
            end loop;
        end loop;

        wait;
    end process;

end behavior;
