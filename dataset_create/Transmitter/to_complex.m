% Assume rx_out is a 3D matrix with size [rows, cols, depth]

% Get dimensions of rx_out
[rows, cols, depth] = size(tensor);

% Pre-allocate the complex output matrix
rx_out_complex = zeros(rows, floor(cols / 2), depth);

% Loop through dimensions
for i = 1:rows
    for j = 1:floor(cols / 2)
        % Create complex numbers using real and imaginary parts
        rx_out_complex(i, j) = tensor(i, j) + 1i * tensor(i, j + floor(cols / 2));
    end
end
