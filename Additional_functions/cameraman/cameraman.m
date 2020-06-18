classdef cameraman < handle
    %CAMERAMAN Point me at a figure and I'll film it until you fire me.
    
    properties
        subject = [];
        destination = [];
        reel = [];
        record = [];
        shutter = [];
        production = [];
        updated = [];
    end
    
    methods
        function obj = cameraman(f, fileName, profile)
            %CAMERAMAN Hire me. Tell me what to film (figure f) and where
            %to show it (fileName)
            obj.subject = f;
            obj.destination = fileName;
            if nargin < 3 || isempty(profile) && strcmp(fileName(end-3:end), '.mp4')
                profile = 'MPEG-4';
            elseif nargin < 3
                profile = [];
            end
            obj.production = VideoWriter(fileName, profile);
            
            % Add input parser later
            obj.production.Quality = 100;
            
            open(obj.production)
            props = metaclass(f);
            props = props.PropertyList;
            props = props([props.SetObservable]); % Use only properties that we can watch
            obj.shutter{1} = addlistener(f, 'ButtonDown', @(src,evnt) obj.snap(obj,src,evnt));
        end
        
        function fire(obj)
            obj.record = false;
            close(obj.production)
            obj.delete
        end
        
        function delete(obj)
        end
        
        function obj = snap(obj, varargin)
            try
                writeVideo(obj.production, getframe(obj.subject));
            catch
                warning('Frame skipped')
            end
        end
        
    end
end
