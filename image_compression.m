% Clear the workspace and close all figures
clc;
clear all;
close all;

% List of image file names and corresponding quantization matrices
imageData = {
    '1.jpg', [ % Quantization matrix for image 1 (Very High Quality)
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
        200 200 200 200 200 200 200 200;
    ],
    '2.jpg', [ % Quantization matrix for image 2 (High Quality)
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
        150 150 150 150 150 150 150 150;
    ],
    '3.jpg', [ % Quantization matrix for image 3 (Medium Quality)
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
        100 100 100 100 100 100 100 100;
    ],
    '4.jpg', [ % Quantization matrix for image 4 (Low Quality)
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
        50 50 50 50 50 50 50 50;
    ],
    '5.jpg', [ % Quantization matrix for image 5 (Very Low Quality)
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
        25 25 25 25 25 25 25 25;
    ],
    '6.jpg', [ % Quantization matrix for image 6 (Extremely Low Quality)
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
        10 10 10 10 10 10 10 10;
    ]
};

% Quantization level labels
quantizationLevels = {
    '200 Quantization matrix',
    '150 Quantization matrix',
    '100 Quantization matrix',
    '50 Quantization matrix',
    '25 Quantization matrix',
    '10 Quantization matrix'
};

% Loop through each image and its corresponding quantization matrix
for k = 1:size(imageData, 1)
    % Load the image
    imageFile = imageData{k, 1};
    quantizationMatrix = imageData{k, 2};
    I = imread(imageFile);
    
    % Display the original image
    figure, imshow(I);
    title(['Original Image - ', imageFile]);
    
    % Color space conversion
    YCbCr = rgb2ycbcr(I);
    Y = double(YCbCr(:,:,1));  % Y channel
    Cb = double(YCbCr(:,:,2)); % Cb channel
    Cr = double(YCbCr(:,:,3)); % Cr channel
    
    % Use the specified quantization matrix
    q80 = quantizationMatrix;
    
    % Compression
    [h, w] = size(Y);
    r = floor(h/8);
    c = floor(w/8);
    compressedY = zeros(h, w);
    compressedCb = zeros(h, w);
    compressedCr = zeros(h, w);
    
    for i = 1:r
        for j = 1:c
            % Extract 8x8 blocks from each channel
            YBlock = Y((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            CbBlock = Cb((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            CrBlock = Cr((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            
            % Apply DCT and quantization to each block
            YDCT = dct2(YBlock - 128);
            CbDCT = dct2(CbBlock - 128);
            CrDCT = dct2(CrBlock - 128);
            
            YQuantized = round(YDCT ./ q80);
            CbQuantized = round(CbDCT ./ q80);
            CrQuantized = round(CrDCT ./ q80);
            
            % Store the quantized coefficients in the corresponding positions
            compressedY((i-1)*8+1:i*8, (j-1)*8+1:j*8) = YQuantized;
            compressedCb((i-1)*8+1:i*8, (j-1)*8+1:j*8) = CbQuantized;
            compressedCr((i-1)*8+1:i*8, (j-1)*8+1:j*8) = CrQuantized;
        end
    end
    
    % Decompression
    reconstructedY = zeros(h, w);
    reconstructedCb = zeros(h, w);
    reconstructedCr = zeros(h, w);
    
    for i = 1:r
        for j = 1:c
            % Extract quantized coefficients from the compressed image
            YQuantized = compressedY((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            CbQuantized = compressedCb((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            CrQuantized = compressedCr((i-1)*8+1:i*8, (j-1)*8+1:j*8);
            
            % Inverse quantization and IDCT
            YDCT = YQuantized .* q80;
            CbDCT = CbQuantized .* q80;
            CrDCT = CrQuantized .* q80;
            
            YBlock = idct2(YDCT) + 128;
            CbBlock = idct2(CbDCT) + 128;
            CrBlock = idct2(CrDCT) + 128;
            
            % Store the reconstructed channels
            reconstructedY((i-1)*8+1:i*8, (j-1)*8+1:j*8) = YBlock;
            reconstructedCb((i-1)*8+1:i*8, (j-1)*8+1:j*8) = CbBlock;
            reconstructedCr((i-1)*8+1:i*8, (j-1)*8+1:j*8) = CrBlock;
        end
    end
    
    % Color space conversion back to RGB
    reconstructedYCbCr = cat(3, uint8(reconstructedY), uint8(reconstructedCb), uint8(reconstructedCr));
    reconstructedRGB = ycbcr2rgb(reconstructedYCbCr);
    figure, imshow(reconstructedRGB);
    title(['Reconstructed Image - ', quantizationLevels{k}]);
    
    % Calculate compression ratio
    originalSize = numel(Y) + numel(Cb) + numel(Cr);
    compressedSize = numel(compressedY) + numel(compressedCb) + numel(compressedCr);
    compressionRatio = originalSize / compressedSize;
    fprintf('Compression Ratio for %s: %.2f\n', imageFile, compressionRatio);
end
