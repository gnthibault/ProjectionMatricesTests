%function [J, grad] = costFunction(theta, X, y)
function [J] = costFunction(coord3DandMatrices, setOf2DPoints)
%COSTFUNCTION Compute cost and gradient for automatic calibration
%   J = COSTFUNCTION(theta, X, y) computes the cost of using theta as the
%   set of parameter for both 3D points coordinates, and projection matrices
%   and the gradient of the cost w.r.t. to the parameters.

% Useful values
NbBalls = size(setOf2DPoints,1);
NbVues = size(setOf2DPoints,3);

%Extract current guess for balls 3d coordinates:
X3d = coord3DandMatrices(1:NbBalls).';
Y3d = coord3DandMatrices(NbBalls+1:2*NbBalls).';
Z3d = coord3DandMatrices(2*NbBalls+1:3*NbBalls).';

%Extract current guess for projection matrices
projMatrices = reshape( coord3DandMatrices(3*NbBalls+1:end),12,NbVues );

% Initialization of the variables to be returned
J = 0;
%grad = zeros(size(theta));

% Let Calibtration Matrix be denoted by (M)
% Writing projection equations of the form AV, where A is a NbVues * 2 * NbBalls * 12 measurement
% matrix accounting for both unknown 3D coordinates and known 2D projection points
% and V is a 12 * NbVues vector accounting for unknown projection matrix.

% Create a Matrix of ones (o) with the same length as that of the u_values
o = ones(size(X3d));
% Create a Matrix of zeros (z) with the same length as that of the u_values
z = zeros(size(X3d));

% Populate the odd rows for A
AoddRows  = [ X3d Y3d Z3d o z z z z ]; %-u_values.*X3d -u_values.*Y3d -u_values.*Z3d -u_values 
% Populate the even rows for A
AevenRows = [ z z z z X3d Y3d Z3d o ]; % -v_values.*X3d -v_values.*Y3d -v_values.*Z3d -v_values ];
% Concatenate odd and even rows of A
A=[AoddRows; AevenRows];

%Result of the 3D to 2D projection part
matProj0 = A*projMatrices(1:8,:);

%Now treating the 2D only part
matProj1 = zeros(size(matProj0));

uPart = zeros(4,NbVues);
vPart = zeros(4,NbVues);
coord3DPart = [ X3d Y3d Z3d o ];

for i=1:1:NbBalls
    uPart = repmat(squeeze(setOf2DPoints(i,1,:)).',4,1);
    vPart = repmat(squeeze(setOf2DPoints(i,2,:)).',4,1);
    matProj1(i,:) = coord3DPart(i,:)*(uPart.*projMatrices(9:12,:));
    matProj1(i+NbBalls-1,:) = coord3DPart(i,:)*(vPart.*projMatrices(9:12,:));
end

J = norm(matProj0-matProj1,'fro')^2;
end
