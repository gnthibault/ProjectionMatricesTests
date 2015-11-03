% Run this first
clc
clear all

% Total number of balls
%NbBalls = 27;
% Read 3-D file
[matrix3D]=textread('3D.txt');

% Read 2-D file
[matrix2D]=textread('2D.txt');

%Total number of projections
NbVues = 50;

% STEP 0 : play along with a 2D and 3D dataset in order to deduce a
% calibration matrix of the scene
[calibMatrix, IntrinseqMatrix, ExtrinseqMatrix, reprojMatrix, avgError_u, avgError_v, timeTaken]= funcCalibrate(matrix3D, matrix2D);

% STEP 1 : generate NbProj projections of the 3D dataset, over 360°
[projectionsMatrices] = generateProjectionsMatrices( IntrinseqMatrix, ExtrinseqMatrix, NbVues);

% STEP 2 : Cast the problem into a non linear optimization scheme in order
% to find all projection matrices + all 3D positions


%Plot the sum of all projection on a single frame
figure;
for i=1:1:NbVues
    m2d = project3DPoints( matrix3D, projectionsMatrices(:,:,i) );
    plot(m2d(:,1),m2d(:,2),'r.');
    hold on;
end

%Plot 3D data
figure;
plot3(matrix3D(:,1),matrix3D(:,2),matrix3D(:,3),'.');
