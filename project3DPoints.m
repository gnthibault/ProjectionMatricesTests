function [newMatrix2D] = project3DPoints( points3D, projectionMatrix )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%Add a column of 1 at the end of the 3D coords
points4D = [ points3D ones(size(points3D,1),1) ];

%Vectorized projection operation
t=projectionMatrix*points4D.';

%The resulting matrix of 2D projected points
newMatrix2D = zeros(2,size(t,2));
newMatrix2D(1,:) = t(1,:)./t(3,:); %u = num_u / den
newMatrix2D(2,:) = t(2,:)./t(3,:); %v = num_v / den
newMatrix2D = newMatrix2D.';

end

