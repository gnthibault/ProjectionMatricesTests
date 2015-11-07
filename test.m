% Run this first
clc
clear all

% Total number of balls
NbBalls = 27;
%Total number of projections
NbVues = 1000;
%Noise while reprojecting
noise = 5e-1;


% Read 3-D file
[matrix3D]=textread('3D.txt');
% Read 2-D file
[matrix2D]=textread('2D.txt');

% STEP 0 : play along with a 2D and 3D dataset in order to deduce a
% calibration matrix of the scene
[calibMatrix, IntrinseqMatrix, ExtrinseqMatrix, reprojMatrix, avgError_u, avgError_v, timeTaken]= funcCalibrate(matrix3D, matrix2D);

% STEP 1 : generate NbProj projections of the 3D dataset, over 360°
[projectionsMatrices] = generateProjectionsMatrices( IntrinseqMatrix, ExtrinseqMatrix, NbVues, noise);

% STEP 2 : generate all corresponding 2D projections inside a vector
setOf2DPoints = zeros( NbBalls, 2, NbVues );
for i=1:1:NbVues
    setOf2DPoints(:,:,i) = project3DPoints( matrix3D, projectionsMatrices(:,:,i) );
end

% STEP 3 : Cast the problem into a non linear optimization scheme in order
% to find all projection matrices + all 3D positions

%  Set options for fminunc
%options = optimset('GradObj', 'on', 'MaxIter', 400);

%  Run fminsearch to obtain the optimal theta, the function return theta and the cost

%validation test
%solution = [ matrix3D(:,1).' matrix3D(:,2).' matrix3D(:,3).' squeeze(reshape(permute(projectionsMatrices,[2 1 3]),12*NbVues,1,1)).' ];
%cost = costFunction(solution, setOf2DPoints )

%[theta, cost] = fminunc(@(t)(costFunction(t, X, y)), initial_theta, options);
options = optimset('MaxIter', 1000,'Display','iter');
initial_solution = rand(1,3*NbBalls+12*NbVues);
%initial_solution = [ matrix3D(:,1).' matrix3D(:,2).' matrix3D(:,3).' squeeze(reshape(permute(projectionsMatrices,[2 1 3]),12*NbVues,1,1)).' ];
[solution, cost] = fminsearch(@(t)(costFunction(t, setOf2DPoints)), initial_solution, options);

%Plot the sum of all projection on a single frame
figure;
for i=1:1:NbVues
    m2d = project3DPoints( matrix3D, projectionsMatrices(:,:,i) );
    plot(m2d(:,1),m2d(:,2),'r.');
    hold on;
end

%Plot 3D data
figure;
plot3(matrix3D(:,1),matrix3D(:,2),matrix3D(:,3),'b.');
hold on;
plot3(solution(1:NbBalls),solution(NbBalls+1:2*NbBalls),solution(2*NbBalls+1:3*NbBalls),'r.');

