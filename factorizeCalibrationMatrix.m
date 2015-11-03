function [IntrinseqMatrix,ExtrinseqMatrix] = factorizeCalibrationMatrix(calibrationMatrix)

% In case the origin of the world frame is in front of the camera, we have
% s=lambda/abs_lambda, or From T_z=s*m_34, we can re-write s in the form of
% sign value of m_34. Here we assume it is in the front.
inFront=1;
if inFront
    s = sign(calibrationMatrix(3,4));
else
    s = -sign(calibrationMatrix(3,4));
end
% Thus, we can now calculate T_z or T(3) 
T(3) = s*calibrationMatrix(3,4);
% Create a 3x3 Rotation matrix and fill it with zeros
R = zeros(3,3);
% From equations, last row of the rotation matrix is the same as the first
% three elements of the last row of the calibration matrix
R(3,:)=s*calibrationMatrix(3,1:3);
% Matrix calibrationMatrix can be written as:
% calibrationMatrix=( m1'   )
%   ( m2' m4)
%   ( m3'   )
% We can now calculate mi, where mi is a 3 element vector
m1 = calibrationMatrix(1,1:3)';
m2 = calibrationMatrix(2,1:3)';
m3 = calibrationMatrix(3,1:3)';
m4 = calibrationMatrix(1:3,4);
% Now, we can calculate the centres of projection u_0 and v_0
u_0 = m1'*m3;
v_0 = m2'*m3;
% Calculating the alpha values in u and v directions,
alpha_u=sqrt( m1'*m1 - u_0^2 );
alpha_v=sqrt( m2'*m2 - v_0^2 );

IntrinseqMatrix = zeros(3,3);
IntrinseqMatrix(1,1) = alpha_u;
IntrinseqMatrix(2,2) = alpha_v;
IntrinseqMatrix(3,3) = 1;
IntrinseqMatrix(1,3) = u_0;
IntrinseqMatrix(2,3) = v_0;


% We can now calculate the first and second rows of the rotation matrix
R(1,:) = s*(u_0*calibrationMatrix(3,1:3) - calibrationMatrix(1,1:3) ) / alpha_u;
R(2,:) = s*(v_0*calibrationMatrix(3,1:3) - calibrationMatrix(2,1:3) ) / alpha_v;
% We can also calculate the first and second elements of the Translation
% vector
T(1) = s*(u_0*calibrationMatrix(3,4) - calibrationMatrix(1,4) ) / alpha_u;
T(2) = s*(v_0*calibrationMatrix(3,4) - calibrationMatrix(2,4) ) / alpha_v;
T = T';
translationVector=T;

% TN: this is a really interesting method to ensure orthogonality of
% rotation matrix, it is slightly different for the QR factorization method
% The rotation matrix R obtained with this estimation procedure is not guaranteed to be orthogonal. 
% Therefore we calculate the rotation matrix that is closest to the estimated matrix (in the 
% Frobenius norm sense). Let R = UDV'T then R = UV'T.
[U,D,V] = svd(R);
R = U*V';
rotationMatrix=R;

ExtrinseqMatrix = [rotationMatrix translationVector];

end