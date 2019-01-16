function sys = supercritical_strogatz()
    % Handles to our SDE functions
    sys.sdeF   = @sdeF;                 % deterministic coefficients
    sys.sdeG   = @sdeG;                 % stochastic coefficints

    % Our SDE parameters
    sys.pardef = [ struct('name','mu',    'value',-0.1);
                   struct('name', 'omega', 'value', pi);
                   struct('name','eta', 'value', 0.1) ];
               
    % Our SDE variables
    sys.vardef =  struct('name','Y', 'value', [1, 1]);
                    
    % Default time span
    sys.tspan = [0 100];
              
   % Specify SDE solvers and default options
    sys.sdesolver = {@sdeEM};           % Relevant SDE solvers
    sys.sdeoption.InitialStep = 0.01;   % SDE solver step size (optional)
    sys.sdeoption.NoiseSources = 1;     % Number of driving Wiener processes

    % Include the Latex (Equations) panel in the GUI
    sys.panels.bdLatexPanel.title = 'Equations'; 
    sys.panels.bdLatexPanel.latex = {'\textbf{Supercritical Strogatz}'};
    
    % Include the Time Portrait panel in the GUI
    sys.panels.bdTimePortrait = [];

    % Include the Solver panel in the GUI
    sys.panels.bdSolverPanel = [];
    
    % Include the Bifurcation panel in the GUI
    sys.panels.bdBifurcation = [];
    
    % Include the Phase Portrait palen in the GUI
    sys.panels.bdPhasePortrait = [];
end

% The deterministic coefficient function.
function F = sdeF(~,Y,mu, omega, ~)  
    %F = mu.*Y - norm(Y).^2.*Y + omega.*fliplr(Y);
    F(1, 1) = mu.*Y(1) - norm(Y).^2.*Y(1) - Y(2).*omega;
    F(2, 1) = mu.*Y(2) - norm(Y).^2.*Y(2) + Y(1).*omega;
end

% The noise coefficient function.
function G = sdeG(~,Y,~, ~,n)  
    G = n.*Y./norm(Y);
end
