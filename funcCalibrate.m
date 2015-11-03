% *************************************************************************
% Title: Function-Produce Calibration Matrix and Average Pixel Error using
% Singular value decomposition (SVD)
% Author: Siddhant Ahuja
% Created: February 2010
% Copyright Siddhant Ahuja, 2010
% ***Inputs***
% 1. File3D: 3-D File containing world coordinates
% 2. File2D: 2-D File containing pixel coordinates
% ***Outputs***
% calibMatrix: 3x4 Calibration Matrix
% rotationMatrix: 3x3 Rotation Matrix
% translationVector: 3x1 Translation vector
% alpha_u: Parameter for scaling in X-direction
% alpha_v: Parameter for scaling in Y-direction
% u_0: Optical Centre of the image (x value)
% v_0: Optical Centre of the image (y value)
% reprojMatrix: Reprojection of 3D points to 2D using Calibration Matrix
% avgError_u: Average Pixel Error in x direction
% avgError_v: Average Pixel Error in y direction
% timeTaken: Time taken by the code
% Example Usage of Function: 
% [calibMatrix, rotationMatrix, translationVector, alpha_u, alpha_v, u_0,
% v_0, reprojMatrix, avgError_u, avgError_v, timeTaken]= funcCalibrate('3D.txt', '2D.txt');
% *************************************************************************
function [calibMatrix, IntrinseqMatrix, ExtrinseqMatrix, reprojMatrix, avgError_u, avgError_v, timeTaken] = funcCalibrate(matrix3D, matrix2D)
  
% Assuming no Radial Distortion is present.
% Initialize the timer to calculate the time consumed.
tic;
% Find the size of the 3D Matrix
[nR3D, nC3D]=size(matrix3D);
% Check to make sure matrix has 3 columns
if(nC3D~=3)
    error('The matrix for 3D points does not have 3 columns.');
end
% Separate out the X values from the matrix
X = matrix3D(:,1);
% Separate out the X values from the matrix
Y = matrix3D(:,2);
% Separate out the X values from the matrix
Z = matrix3D(:,3);
% Find the size of the 2D Matrix
[nR2D, nC2D]=size(matrix2D);
% Check to make sure matrix has 2 columns
if(nC2D~=2)
    error('The matrix for 2D points does not have 2 columns.');
end
% Separate out the u values from the matrix
u_values=matrix2D(:,1);
% Separate out the v values from the matrix
v_values=matrix2D(:,2);
% Plot the points in 2-D
%figure;
%plot(matrix2D(:,1),matrix2D(:,2),'b.');
%hold on;

% Check to make sure number of rows of the 3D Matrix is the same as the
% number of rows of the 2D Matrix
if(nR3D~=nR2D)
    error('Please make sure number of 3D and 2D points is the same.');
end


% ***Linear Solution of the Calibration Matrix***
% Let Calibtration Matrix be denoted by (M)
% Writing linear equations of the form AV=0, where A is a 2nx12 measurement
% matrix and V is a 12-element unknown vector.
% Create a Matrix of ones (o) with the same length as that of the u_values
% vector
o = ones(size(u_values));
% Create a Matrix of zeros (z) with the same length as that of the u_values
% vector
z = zeros(size(u_values));
% Populate the odd rows for A
AoddRows  = [ X Y Z o z z z z -u_values.*X -u_values.*Y -u_values.*Z -u_values ];
% Populate the even rows for A
AevenRows = [ z z z z X Y Z o -v_values.*X -v_values.*Y -v_values.*Z -v_values ];
% Concatenate odd and even rows of A
A=[AoddRows; AevenRows];


% Now that the matrix of the problem is set, we will find the solution of
% Ax=0 using SVD
[U, S, V] = svd(A,0);
% Assuming no noise, since the elements of the diagonal matrix S are in descending order, to
% get the eigenvectors corresponding to the smallest eignevalue, we can
% just grab the last column of matrix 
m = V(:,end);
% Construct the camera calibration matrix M
M = reshape(m,4,3)';
calibMatrix=M;

% Since the norm of Projection matrix M is equal to 1, we can calculate the
% absolute scale factor lambda
abs_lambda=sqrt(M(3,1)^2 + M(3,2)^2 + M(3,3)^2);
% Scale the Matrix with the scale factor
M = M / abs_lambda;

[IntrinseqMatrix,ExtrinseqMatrix] = factorizeCalibrationMatrix(M)

% Reproject 3Dpoints to 2D points using the calibration matrix to calculate average pixel errors 
reprojMatrix = project3DPoints( matrix3D, M );

% Plot Reprojected points
%plot(reprojMatrix(:,1),reprojMatrix(:,2),'r.');
%hold on;



% Calculate difference between the reprojectedMatrix and the original 2D
% Matrix
errorDiff=reprojMatrix-matrix2D;
% Calculate average pixel error in x direction
avgError_u=mean(errorDiff(:,1));
% Calculate average pixel error in y direction
avgError_v=mean(errorDiff(:,2));
% Stop the timer to calculate the time consumed.
timeTaken=toc;