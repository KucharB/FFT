import numpy as np

def convert_real_to_hex(input_filename, output_filename="real_factors.hex", width=16):
    """
    Convert real values from a text file into a hex file in 2's complement format.

    Parameters:
    - input_filename: Name of the input text file containing real values.
    - output_filename: Name of the output hex file.
    - width: Bit-width of each value (default 16-bit).
    """
    # Calculate scale factor for 2's complement representation
    scale = 2**(width - 1) - 1  # 2^(width-1) - 1 corresponds to the range -1 to +1

    # Read real values from the input file
    with open(input_filename, "r") as f:
        real_values = [float(line.strip()) for line in f]

    # Convert real values to fixed-point representation (2's complement)
    fixed_point_values = []
    for value in real_values:
        # Scale the value and round to nearest integer
        fixed_point = int(np.round(value * scale))

        # Handle 2's complement conversion for negative values
        if fixed_point < 0:
            fixed_point = (1 << width) + fixed_point

        fixed_point_values.append(fixed_point)

    # Write to the hex file
    with open(output_filename, "w") as f:
        for fixed_point in fixed_point_values:
            f.write(f"{fixed_point:04X}\n")  # Write as hex with zero padding

    print(f"Real values converted and written to {output_filename}")

# Example usage
convert_real_to_hex("real_values.txt")
