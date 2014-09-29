function NMR(varargin)
p = mfilename('fullpath');
p=[p '.m'];
[pathstr, ~] = fileparts(p);
addpath(pathstr)
mainmenu(varargin)