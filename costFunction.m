function [J, grad] = costFunction(theta, X, y)
%COSTFUNCTION Compute cost and gradient for automatic calibration
%   J = COSTFUNCTION(theta, X, y) computes the cost of using theta as the
%   set of parameter for both 3D points coordinates, and projection matrices
%   and the gradient of the cost w.r.t. to the parameters.

% Useful values
NbBalls = 0;
NbVues = 0;

%Extract current guess for balls 3d coordinates:
X3d = theta(1:2);
Y3d = theta(1:2);
Z3d = theta(1:2);

%Extract current guess for projection matrices
P = zeros(3,4,NbVues);
for i=1:1:NbVues
    firstIdx = 1+2*NbBalls+12*i;
    P(:,:,i) = reshape(theta(firstIdx:firstIdx+12),4,3)';
end

% Initialization of the variables to be returned
J = 0;
grad = zeros(size(theta));

% Let Calibtration Matrix be denoted by (M)
% Writing projection equations of the form AV, where A is a NbVues * 2 * NbBalls * 12 measurement
% matrix accounting for both unknown 3D coordinates and known 2D projection points
% and V is a 12 * NbVues vector accounting for unknown projection matrix.

% Create a Matrix of ones (o) with the same length as that of the u_values
o = ones(NbBalls);
% Create a Matrix of zeros (z) with the same length as that of the u_values
z = zeros(NbBalls);

% Populate the odd rows for A
AoddRows  = [ X3d Y3d Z3d o z z z z -u_values.*X3d -u_values.*Y3d -u_values.*Z3d -u_values ];
% Populate the even rows for A
AevenRows = [ z z z z X Y Z o -v_values.*X3d -v_values.*Y3d -v_values.*Z3d -v_values ];
% Concatenate odd and even rows of A
A=[AoddRows; AevenRows];


end
