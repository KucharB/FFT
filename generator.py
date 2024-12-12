import numpy as np

def generate_twiddle_factors(filename="twiddle_factors.hex", n=4096, width=16):
    """
    Generate a hex file containing twiddle factors in 2's complement format.

    Parameters:
    - filename: Name of the output hex file.
    - n: Number of twiddle factors (depth of ROM).
    - width: Bit-width of each factor (default 16-bit).
    """
    # Check bit-width constraints
    max_val = 2**(width - 1) - 1  # Max positive value
    min_val = -2**(width - 1)     # Min negative value

    # Generate twiddle factors (real and imaginary parts) using e^(-j*2*pi*k/N)
    twiddle_factors = [
        np.exp(-2j * np.pi * k / n) for k in range(n)
    ]

    # Convert to fixed-point representation (2's complement)
    fixed_point_factors = []
    for factor in twiddle_factors:
        real = int(np.round(factor.real * max_val))
        imag = int(np.round(factor.imag * max_val))

        # Clamp to the range of 2's complement
        real = max(min(real, max_val), min_val)
        imag = max(min(imag, max_val), min_val)

        # Combine real and imaginary parts into a single 16-bit value
        # Upper 8 bits: real, Lower 8 bits: imag
        fixed_point_value = ((real & 0xFFFF) << 16) | (imag & 0xFFFF)
        fixed_point_factors.append(fixed_point_value)

    # Write to the hex file
    with open(filename, "w") as f:
        for value in fixed_point_factors:
            f.write(f"{value:08X}\n")

    print(f"Twiddle factors written to {filename}")

# Generate the twiddle factors file
generate_twiddle_factors()
