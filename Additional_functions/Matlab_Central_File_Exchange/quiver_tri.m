function quiver_tri(x,y,u,v,varargin)
%QUIVER_TRI Quiver plot with filled triangles
%   QUIVER_TRI(x,y,u,v) plots velocity vectors with filled triangle arrows.
%   Contrary to QUIVER, QUIVER_TRI does not scale vectors before plotting
%   them. Vectors will be plotted with the same spacing and magnitude as
%   they are provided. Default head arrow size is 20% of the median
%   magnitude and default head angle is 22.5 degrees.
%
%   QUIVER_TRI(x,y,u,v,headsize) plots velocity vectors specifying the
%   headsize (same units as u and v).
%
%   QUIVER_TRI(x,y,u,v,headsize,headangle) plots velocity vectors
%   specifying the head size (same units as u and v) and the head angle
%   amplitude (in degrees).
%
%   QUIVER_TRI(x,y,u,v,headsize,headangle,width) same as before, plus
%   setting of the quiver body width
%
%   QUIVER_TRI(x,y,u,v,headsize,headangle,width,col) same as before, plus
%   setting of the color
%
%   See also QUIVER.
%
%   Author: Alessandro Masullo 2015

if nargin == 0
    load wind
    x = x(:,:,5);
    y = y(:,:,5);
    u = u(:,:,5)/7;
    v = v(:,:,5)/7;
    triL = median(sqrt(u(:).^2+v(:).^2))/5;
    triA = 22.5;
    width = 1;
    col = 'k';
end

if nargin == 4
    triL = median(sqrt(u(:).^2+v(:).^2))/5;
    triA = 22.5;
    width = 1;
    col = 'k';
end

if nargin == 6
    triL = varargin{1};
    triA = varargin{2};
    width = 1;
    col = 'k';
end

if nargin == 7
    triL = varargin{1};
    triA = varargin{2};
    width = varargin{3};
    col = 'k';
end

if nargin == 8
    triL = varargin{1};
    triA = varargin{2};
    width = varargin{3};
    col = varargin{4};
end

triA = triA/180*pi;

% Coordinates of the triangle in vertex reference system
V = [0; 0];
U = [-triL*cos(triA); triL*sin(triA)];
B = [-triL*cos(triA); -triL*sin(triA)];
C = [-triL*cos(triA); 0];

t = atan2(v(:),u(:));

figure(gcf),ish = ishold; hold on

Vt = zeros(numel(u),2);
Ut = zeros(numel(u),2);
Bt = zeros(numel(u),2);
Ct = zeros(numel(u),2);

% Change coordinate system of the triangles
for i = 1:numel(u)
    % Rotate and translate the triangle to the right position
    M = [cos(t(i)) -sin(t(i)); sin(t(i)) cos(t(i))];
    T = [x(i)+u(i); y(i)+v(i)];
    
    Vt(i,:) = M*V + T;
    Ut(i,:) = M*U + T;
    Bt(i,:) = M*B + T;
    Ct(i,:) = M*C + T;
end

% Plot the arrow lines
plot([x(:)'; Ct(:,1)'],[y(:)'; Ct(:,2)'],'-','linewidth',width,'color',col)
% Plot the triangle heads
patch([Vt(:,1)'; Ut(:,1)'; Bt(:,1)'; Vt(:,1)'],[Vt(:,2)'; Ut(:,2)'; Bt(:,2)'; Vt(:,2)'],col,'EdgeColor',col)

if ~ish
    hold off
end
