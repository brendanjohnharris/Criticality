function sys = supercritical_hopf_strogatz_radius()
    % Handles to our SDE functions
    sys.sdeF   = @sdeF;                 % deterministic coefficients
    sys.sdeG   = @sdeG;                 % stochastic coefficints

    % Our SDE parameters
    sys.pardef = [ struct('name','mu',    'value',-0.1, 'lim',[-1 1]);
                   struct('name','eta', 'value', 0.1, 'lim',[0 1]) ];
               
    % Our SDE variables
    sys.vardef =  struct('name','r', 'value', 1, 'lim',[-2 2]);
                    
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
    
end

% The deterministic coefficient function.
function F = sdeF(~,Y,mu, ~)  
    F = mu.*Y - Y.^3;
end

% The noise coefficient function.
function G = sdeG(~,Y,~,n)  
    G = n;
end
