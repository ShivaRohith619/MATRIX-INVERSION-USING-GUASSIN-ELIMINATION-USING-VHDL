library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

package MatrixPackage is
    type MATRIX is array (0 to 2, 0 to 2) of REAL;
end package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use work.MatrixPackage.all;

entity MatrixInversion is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        start  : in  STD_LOGIC;
        A      : in  MATRIX;
        inv_A  : out MATRIX;
        idone  : out STD_LOGIC
    );
end MatrixInversion;

architecture Behavioral of MatrixInversion is

    type STATE_TYPE is (IDLE, INIT, NORM_ROW, ELIM_ROW, NEXT_PIVOT, DONE);
    signal state : STATE_TYPE := IDLE;

    signal mat   : MATRIX := ((others => (others => 0.0)));
    signal Ident : MATRIX := ((others => (others => 0.0)));  

    signal pivot_row : INTEGER := 0;
    signal elimi_row : INTEGER := 0;

begin

    process(clk, reset)
        variable pivot  : REAL;
        variable factor : REAL;
    begin
        if reset = '1' then
            state <= IDLE;
            idone <= '0';
        elsif rising_edge(clk) then
            case state is

                when IDLE =>
                    idone <= '0';
                    if start = '1' then
                        state <= INIT;
                    end if;

                when INIT =>
                    for row in 0 to 2 loop
                        for col in 0 to 2 loop
                            mat(row, col) <= A(row, col);
                            if row = col then
                                Ident(row, col) <= 1.0;
                            else
                                Ident(row, col) <= 0.0;
                            end if;
                        end loop;
                    end loop;
                    pivot_row <= 0;
                    state <= NORM_ROW;

                when NORM_ROW =>
                    pivot := mat(pivot_row, pivot_row);
                    if pivot /= 0.0 then
                        for col in 0 to 2 loop
                            mat(pivot_row, col) <= mat(pivot_row, col) / pivot;
                            Ident(pivot_row, col) <= Ident(pivot_row, col) / pivot;
                        end loop;
                        elimi_row <= 0;
                        state <= ELIM_ROW;
                    else
                        idone <= '1';
                        state <= IDLE;
                    end if;

                when ELIM_ROW =>
                    if elimi_row < 3 then
                        if elimi_row /= pivot_row then
                            factor := mat(elimi_row, pivot_row);
                            for col in 0 to 2 loop
                                mat(elimi_row, col) <= mat(elimi_row, col) - factor * mat(pivot_row, col);
                                Ident(elimi_row, col) <= Ident(elimi_row, col) - factor * Ident(pivot_row, col);
                            end loop;
                        end if;
                        elimi_row <= elimi_row + 1;
                    else
                        state <= NEXT_PIVOT;
                    end if;

                when NEXT_PIVOT =>
                    if pivot_row < 2 then
                        pivot_row <= pivot_row + 1;
                        state <= NORM_ROW;
                    else
                        state <= DONE;
                    end if;

                when DONE =>
                    for row in 0 to 2 loop
                        for col in 0 to 2 loop
                            inv_A(row, col) <= Ident(row, col);
                        end loop;
                    end loop;
                    idone <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end Behavioral;
