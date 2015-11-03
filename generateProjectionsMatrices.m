function projectionsMatrices = generateProjectionsMatrices( IntrinseqMatrix, ExtrinseqMatrix, NbVues)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

projectionsMatrices = zeros(3,4,NbVues);

%Rotation around X axis
Xtheta = 0;
Xrot = zeros(3,3);
Xrot(1,1) = 1;
Xrot(2,2) = cos(Xtheta);
Xrot(2,3) = -sin(Xtheta);
Xrot(3,2) = sin(Xtheta);
Xrot(3,3) = cos(Xtheta);

%Rotation around Y axis
Ytheta = 0;
Yrot = zeros(3,3);
Yrot(1,1) = cos(Ytheta);
Yrot(1,3) = sin(Ytheta);
Yrot(2,2) = 1;
Yrot(3,1) = -sin(Ytheta);
Yrot(3,3) = cos(Ytheta);

%Rotation around Z axis
Ztheta = 0;
Zrot = zeros(3,3);
Zrot(1,1) = cos(Ztheta);
Zrot(1,2) = -sin(Ztheta);
Zrot(2,1) = sin(Ztheta);
Zrot(2,2) = cos(Ztheta);
Zrot(3,3) = 1;
    
for i=1:1:NbVues
    translationVector = ExtrinseqMatrix(:,4);
    rotationMatrix = ExtrinseqMatrix(:,1:3);

    %Generating the right rotation matrix around axis Z
    Ytheta = i*((2*pi)/NbVues);
    Yrot(1,1) = cos(Ytheta);
    Yrot(1,3) = sin(Ytheta);
    Yrot(3,1) = -sin(Ytheta);
    Yrot(3,3) = cos(Ytheta);

    %Final rotation Matrix is the product of these 3 matrices
    atomicRotationMatrix = Zrot*Yrot*Xrot;
    
    %Concatenate rotation and translation for Extrinseq matrix
    NewExtrinseqMatrix = [atomicRotationMatrix*rotationMatrix translationVector];
    
    %Projection matrix is the product between Intrinseq and extrinseq
    projectionsMatrices(:,:,i) = IntrinseqMatrix*NewExtrinseqMatrix;
end

end

