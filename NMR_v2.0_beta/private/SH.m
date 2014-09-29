%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   This function computes the modified spherical harmonic
%%   basis (SH), the ADCs, the odfs and the GFAs for a HARDI 
%%   dataset. The algorithm is summarized in Table 7.1 of 
%%   Maxime's thesis.
%%
%%
%%   Inputs needed to compute SH basis (TASK = 2):
%%
%%      gradfile   := file containing gradient directions
%%      n_s        := number of gradients 
%%      rankSH     := number of SH coefficients
%%                    order 4,6,8, -> 15,28,45 coeffs 
%%                    and in general, if N = number of coeffs, 
%%                    N = (1/2)(order+1)(order+2) 
%%
%%   Inputs needed to obtain the coefficients of SH, the
%%   odfs and the GFA (TASK = 3):   
%%
%%     datafile := input data file
%%     lambda   := regularization parameter; default is 0.006.
%%                 usually no need to change it.
%%     odf      := if odf==0, then TASK 3 computes the ADC in  
%%                 the SH basis. If odf==1, then TASK 3
%%                 computes the odf in the SH basis. Default 
%%                 odf = 1.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch TASK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Maxime's Spherical Harmonic basis, modified from regular SH
% so that all values are real (see p.66 in Maxime's thesis). 
%
% inputs: l         := order of spherical harmonic
%         theta,phi := coordinates on the sphere of the SH
%
% ouputs: Ylm_modif: modified SH basis for l and m=-l:l at
%                    position theta, phi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

case 1

  %regular spherical harmonic basis
  m = 0:l;
  
  Ylm = sqrt((2*l+1)/(4*pi)*(factorial(l - m)./factorial(l + m))).*legendre(l,cos(theta))'.*exp(i*m*phi);

  %modify it to make it real
  clear Ylm_modif
  Ylm_modif(1:l) = sqrt(2).*real(Ylm((l+1):-1:2));
  Ylm_modif(l+1) = Ylm(1);
  Ylm_modif((l+2):(2*l+1)) = sqrt(2)*(-1).^(m(2:(l+1))+1).*imag(Ylm(2:(l+1)));
  
  clear m Ylm
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the SH matrix for discrete samplings on the sphere
%
%  inputs:
%    rankSH := number of spherical harmonics  
%    grad   := gradient directions 
%    n_s    := number of gradients  
%
%  outputs: 
%    B      := matrix containing the SHs values at all the 
%              gradient directions
%    PhiThetaDirections := coordinates (theta,phi) at each 
%                          gradient direction
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

case 2
    
   %inputs
   if ~exist('grad')   gradfile = input('Enter file containing gradient directions > '); grad = load(gradfile); end 
   if ~exist('n_s')    n_s = input('Enter number of gradient directions > '); end
   if ~exist('rankSH') rankSH = input('Enter number of spherical harmonic coefficients (15,28,45...) > '); end 

   %loop over all points where we need basis functions
   B = zeros(rankSH,n_s);
   for(a = 1:n_s)

     %get spherical component of the point direction we need it in spherical coordinates
     p = grad(a,:); 
     
	 r = sqrt(sum(p(:).^2));
     theta = acos(p(3)/r);  
     phi = atan2(p(2),p(1)); 
        
     PhiThetaDirections(a,1) = phi;
     PhiThetaDirections(a,2) = theta;

     %Generate the modified Spherical Harmonic basis
     order = -3/2 + sqrt(9/4 - 2*(1 - rankSH));
     for (l = 0:2:order)
	
       TASK = 1; SH;
       M = -l:l;
       B((l^2+l+2)/2 + M, a) = Ylm_modif;   
     
     end 
   end	
   
   clear a p r theta phi M l

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the ADC or ODF and the GFA at each voxel
%
%  Sharpening is just an ad hoc enhancement of the ODF maxima
%  The correct way to do things should be to deconvolve the ODF
%  just like done in Descoteaux et al latest research report
%  
%  inputs:
%
%    datafile := input data file
%    lambda   := regularization parameter
%    sharpen  := Sharpening of the odf
%    sharp_factor := Sharpness of profile
%    odf      := 0 for ADC, 1 for ODF 
%
%  outputs:  
%
%    data_SH  := voxelwise ADC or ODF
%    GFA      := voxelwise GFA
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   
case 3
    
  %inputs
  if ~exist('data')         datafile = input('Enter file containing data > '); data = load(datafile); end 
  if ~exist('lambda')       lambda = 0.006; end
  if ~exist('sharpen')      sharpen = 0; end  % No sharpening by default
  if ~exist('sharp_factor') sharp_factor = 0.5; end 
  if ~exist('odf')          odf = 1; end
                    
  Nx=size(data,1); Ny=size(data,2); Nz=size(data,3);
  
  %loop to get the regularization strength (L) and the multiplication
  %factor transform the ADC into an odf (P)
  clear L P
  k = 1;
  for l = 0:2:order  
    
    diagl = 2*pi*legendre(l,0);
    diagP = diagl(1);

    for m = -l:l
        
      L(k,k) = l^2*(l+1)^2;

      if(sharpen == 1)
        P(k,k) = diagP*(sharp_factor*l*(l+1) + 1);
      else
        P(k,k) = diagP;
      end
      
      k = k+1;
      
    end
  end 
  
  %compute the coefficients of the SH
  least_square = inv(B*B' +  lambda*L)*B;

  %if odf, compute the odf coefficients for the SH
  if(odf) least_square = P*least_square; end
  
  for(ix = 1:Nx)
    for(iy = 1:Ny)
      for(iz = 1:Nz)  
          
        %compute the ADCs of odfs  
        data_SH(ix,iy,iz,:) = double(least_square)*double(squeeze(data(ix,iy,iz,:)));
        
        %compute the GFA
        if(sum(squeeze(data_SH(ix,iy,iz,:).^2)) == 0)  
            GFA(ix,iy,iz) = 0;
        else
            GFA(ix,iy,iz) = sqrt(1 - squeeze(data_SH(ix,iy,iz,1))^2 ...
            / sum(squeeze(data_SH(ix,iy,iz,:).^2)));
        end
      end
    end 
  end
 
%   plot the GFA
%   figure
%   hold on
%   imagesc(squeeze(GFA(floor(Nx/2),:,:)))
%   colorbar
%   hold off
  
  clear ix iy iz k P m diagl diagP
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
