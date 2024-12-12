import numpy as np

def generate_twiddle_factors(filename="twiddle_factors.hex", n=16, width=16):
    """
    Generate a hex file containing twiddle factors in 2's complement format.
    
    Parameters:
    - filename: Name of the output hex file.
    - n: Number of twiddle factors (depth of ROM).
    - width: Bit-width of each factor (default 16-bit).
    """
    # Calculate scale factor for 2's complement representation
    scale = 2**(width - 1)  # 2^(width-1) corresponds to the range -1 to +1
    print(scale)

    # Generate twiddle factors (real and imaginary parts)
    twiddle_factors = [
        np.exp(-2j * np.pi * k / n) for k in range(n)
    ]

    # Convert to fixed-point representation (2's complement)
    fixed_point_factors = []
    for factor in twiddle_factors:
        real = int(np.round(factor.real * scale)) & 0xFFFF  # Real part as 2's complement
        imag = int(np.round(factor.imag * scale)) & 0xFFFF  # Imaginary part as 2's complement
        print(real)
        
        # Store as two separate values
        fixed_point_factors.append((real, imag))

    # Write to the hex file
    with open(filename, "w") as f:
        for real, imag in fixed_point_factors:
            f.write(f"{real:04X}{imag:04X}\n")  # Write real and imaginary as hex
    
    print(f"Twiddle factors written to {filename}")

# Generate the twiddle factors file
generate_twiddle_factors()
