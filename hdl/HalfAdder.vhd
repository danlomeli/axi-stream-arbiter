library IEEE;
use IEEE.std_logic_1164.all;

entity HalfAdder is

  port (
    a : in  std_logic;                  -- 1st Argument to add
    b : in  std_logic;                  -- 2nd Argument to add
    s : out std_logic;                  -- The sum of a and b
    c : out std_logic);                 -- Did a cary occur?

end HalfAdder;

architecture Behavior of HalfAdder is

  -- two internal signals I will need later
  signal a_xor_b : std_logic;   
  signal a_and_b : std_logic;

begin

  -- Truth Table for a half adder:
  --     
  --     a b | s c
  --     --- | ---
  --     0 0 | 0 0
  --     0 1 | 1 0
  --     1 0 | 1 0
  --     1 1 | 0 1

  -- Note that:
  -- s = a xor b   (the sum is 1, when exactly one of the args is 1)
  -- c = a and b   (the cary is 1, when both of the args is 1)

  -- compute the needed values
  a_xor_b <= a xor b;
  a_and_b <= a and b;

  -- Attach the signals to the outputs
  s <= a_xor_b;
  c <= a_and_b;

end Behavior;
