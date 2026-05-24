function BrainWaveStudio()
% BrainWave Studio
% ─────────────────────────────────────────────────────
% MATLAB ONLINE SETUP (do this once):
%   1. Go to Home tab → Layout → Undock Figure
%   OR: In the figure titlebar, click the arrow icon to undock
%   2. Then run this file — GUI opens in its own window
% ─────────────────────────────────────────────────────

clc; close all;

%% ── Colours ──────────────────────────────────────────────
C.bg    = [0.99 0.96 0.97];
C.panel = [0.97 0.91 0.94];
C.rose  = [0.87 0.47 0.63];
C.pink  = [0.95 0.75 0.82];
C.plum  = [0.62 0.35 0.55];
C.butter= [0.95 0.82 0.55];
C.mint  = [0.67 0.88 0.80];
C.text  = [0.25 0.15 0.22];
C.muted = [0.55 0.40 0.50];
C.white = [1.00 1.00 1.00];
C.grid  = [0.92 0.87 0.90];
C.teal  = [0.20 0.65 0.72];   % Chebyshev colour in compare mode

%% ── State ────────────────────────────────────────────────
state.mode       = 'mood';
state.filterType = 'butter';
state.compare    = false;
state.label      = '';

%% ── Figure ───────────────────────────────────────────────
scr = get(0,'ScreenSize');
FW  = max(900, min(1400, scr(3) - 20));
FH  = max(500, min(620,  scr(4) - 200));
fig = figure('Name','BrainWave Studio', ...
    'NumberTitle','off','Color',C.bg, ...
    'Position',[10, max(50, scr(4)-FH-80), FW, FH], ...
    'MenuBar','none','ToolBar','figure','Resize','on', ...
    'WindowStyle','normal');

LW = 190;   % left panel width px
PL = LW/FW;

%% ── Header ───────────────────────────────────────────────
hAx = axes('Parent',fig, ...
    'Position',[0, 1-60/FH, 1, 60/FH], ...
    'XTick',[],'YTick',[],'XLim',[0 1],'YLim',[0 1], ...
    'Color',C.rose,'Box','off','HitTest','off');
text(0.5,0.58,'BrainWave Studio','Parent',hAx, ...
    'HorizontalAlignment','center','FontSize',18, ...
    'FontWeight','bold','Color',C.white);
text(0.5,0.16,'Mood  |  Sleep  |  Focus        Brainwave Simulation & Filter Analysis', ...
    'Parent',hAx,'HorizontalAlignment','center', ...
    'FontSize',8.5,'Color',C.white);

%% ── Left panel background ────────────────────────────────
annotation(fig,'rectangle',[0, 0, PL, 1-60/FH], ...
    'FaceColor',C.panel,'EdgeColor',C.pink,'LineWidth',0.8);

%% ── Helper: place uicontrol in left panel ────────────────
    function h = lc(style, x, y, w, h_, str, bg, fg, fs, cb)
        yn = 1 - (60 + y + h_)/FH;
        props = {'Parent',fig,'Style',style,'String',str, ...
            'Units','normalized', ...
            'Position',[x/FW, yn, w/FW, h_/FH], ...
            'BackgroundColor',bg,'ForegroundColor',fg,'FontSize',fs};
        if ~isempty(cb), props = [props {'Callback',cb}]; end
        h = uicontrol(props{:});
    end

%% ── Left panel controls ──────────────────────────────────
secH = 20; btnH = 36; gap = 6;
y = 10;

lc('text',5,y,180,secH,'MODE',C.rose,C.white,8,[]); y=y+secH+4;
btnMood  = lc('pushbutton',5,y,180,btnH,'Mood Check', C.plum,C.white,10,@(~,~)setMode('mood'));  y=y+btnH+gap;
btnSleep = lc('pushbutton',5,y,180,btnH,'Sleep Check', C.pink,C.text, 10,@(~,~)setMode('sleep')); y=y+btnH+gap;
btnFocus = lc('pushbutton',5,y,180,btnH,'Focus Check',C.mint,C.text, 10,@(~,~)setMode('focus')); y=y+btnH+gap+6;

lc('text',5,y,180,secH,'BRAIN STATE',C.rose,C.white,8,[]); y=y+secH+4;
ddSignal = lc('popupmenu',5,y,180,btnH,'Loading...',C.white,C.text,9,@(~,~)generateSignal()); y=y+btnH+gap+6;

lc('text',5,y,180,secH,'FILTER',C.rose,C.white,8,[]); y=y+secH+4;
btnButter  = lc('pushbutton',5,y,180,btnH,'Butterworth', C.butter,C.text,9,@(~,~)setFilter('butter')); y=y+btnH+gap;
btnCheby   = lc('pushbutton',5,y,180,btnH,'Chebyshev I', C.pink,  C.text,9,@(~,~)setFilter('cheby'));  y=y+btnH+gap;
btnCompare = lc('pushbutton',5,y,180,btnH,'Compare Both ⇄', [0.82 0.70 0.88],C.text,9,@(~,~)toggleCompare()); y=y+btnH+gap+6;

lc('text',5,y,180,secH,'NOISE LEVEL',C.rose,C.white,8,[]); y=y+secH+4;
slNoise = lc('slider',5,y,180,26,'',C.panel,C.text,9,@(~,~)generateSignal());
set(slNoise,'Min',0.1,'Max',1.8,'Value',0.5); y=y+26+gap+6;

lc('text',5,y,180,secH,'ACTIONS',C.rose,C.white,8,[]); y=y+secH+4;
lc('pushbutton',5,y,180,btnH,'Generate Signal',C.plum, C.white,10,@(~,~)generateSignal()); y=y+btnH+gap;
lc('pushbutton',5,y,180,btnH,'Save Report',    C.rose, C.white,10,@(~,~)saveReport());     y=y+btnH+gap;
lc('pushbutton',5,y,180,btnH,'Reset',          [0.86 0.84 0.85],C.muted,9,@(~,~)resetAll()); y=y+btnH+gap+8;

lc('text',5,y,180,secH,'BRAIN VERDICT',C.rose,C.white,8,[]); y=y+secH+4;
txtVerdict = lc('text',5,y,180,88,'Press Generate!',C.white,C.plum,9,[]);
set(txtVerdict,'HorizontalAlignment','center');

%% ── Score strip ──────────────────────────────────────────
cardLabels = {'SNR Score','Dominant Band','Filter Used','State'};
scoreCards = gobjects(4,1);
cardW = floor((FW - LW - 30) / 4);
for k = 1:4
    xpx = LW + 8 + (k-1)*cardW;
    uicontrol('Parent',fig,'Style','text','String',cardLabels{k}, ...
        'Units','normalized', ...
        'Position',[xpx/FW, 1-79/FH, (cardW-4)/FW, 15/FH], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.muted, ...
        'FontSize',7.5,'HorizontalAlignment','center');
    scoreCards(k) = uicontrol('Parent',fig,'Style','text','String','——', ...
        'Units','normalized', ...
        'Position',[xpx/FW, 1-104/FH, (cardW-4)/FW, 24/FH], ...
        'BackgroundColor',C.white,'ForegroundColor',C.plum, ...
        'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
end

%% ── Plot axes (normal mode: 2×2) ────────────────────────
RX = PL + 0.015;
RW = 1 - RX - 0.015;
RY1 = 0.04; RH = 0.38; RY2 = RY1+RH+0.05;
AW  = RW/2 - 0.012;

normalPos = { ...
    [RX,         RY2, AW, RH];   % top-left:  raw
    [RX+AW+0.01, RY2, AW, RH];   % top-right: filtered
    [RX,         RY1, AW, RH];   % bot-left:  spectrum before
    [RX+AW+0.01, RY1, AW, RH];   % bot-right: spectrum after
};

% Compare mode: 2×2 — top row time domain, bot row freq response
AW2 = RW/2 - 0.012;
comparePos = { ...
    [RX,         RY2, AW2, RH];   % top-left:  Butterworth time
    [RX+AW2+0.01,RY2, AW2, RH];   % top-right: Chebyshev time
    [RX,         RY1, AW2, RH];   % bot-left:  Butterworth freq resp
    [RX+AW2+0.01,RY1, AW2, RH];   % bot-right: Chebyshev freq resp
};

ax = gobjects(4,1);
for k = 1:4
    ax(k) = axes('Parent',fig,'Position',normalPos{k}, ...
        'Color',C.white,'XColor',C.muted,'YColor',C.muted, ...
        'GridColor',C.grid,'GridAlpha',1,'FontSize',8, ...
        'Box','on','XGrid','on','YGrid','on');
    text(0.5,0.5,'— press Generate —','Parent',ax(k), ...
        'Units','normalized','HorizontalAlignment','center', ...
        'Color',C.muted,'FontSize',9);
end

%% ── setMode ──────────────────────────────────────────────
    function setMode(m)
        state.mode = m;
        set(btnMood, 'BackgroundColor',C.rose, 'ForegroundColor',C.white);
        set(btnSleep,'BackgroundColor',C.pink, 'ForegroundColor',C.text);
        set(btnFocus,'BackgroundColor',C.mint, 'ForegroundColor',C.text);
        switch m
            case 'mood'
                set(ddSignal,'String', ...
                    {'Happy  (Alpha 10 Hz)','Stressed  (Beta 20 Hz)', ...
                     'Sleepy  (Theta 6 Hz)','Calm  (Alpha 8 Hz)', ...
                     'Anxious  (Beta 25 Hz)','Deep Sleep  (Delta 2 Hz)'});
                set(btnMood,'BackgroundColor',C.plum);
            case 'sleep'
                set(ddSignal,'String', ...
                    {'8 hrs  — Well Rested','6 hrs  — A Little Tired', ...
                     '4 hrs  — Sleep Deprived','2 hrs  — Zombie Mode'});
                set(btnSleep,'BackgroundColor',C.plum,'ForegroundColor',C.white);
            case 'focus'
                set(ddSignal,'String', ...
                    {'Deep Focus  (Beta 18 Hz)','Study Mode  (Alpha+Beta)', ...
                     'Daydreaming  (Theta 5 Hz)','Overwhelmed  (Gamma 40 Hz)'});
                set(btnFocus,'BackgroundColor',C.plum,'ForegroundColor',C.white);
        end
        generateSignal();
    end

%% ── setFilter ────────────────────────────────────────────
    function setFilter(f)
        state.filterType = f;
        state.compare    = false;
        set(btnCompare,'BackgroundColor',[0.82 0.70 0.88],'ForegroundColor',C.text);
        if strcmp(f,'butter')
            set(btnButter,'BackgroundColor',C.plum,'ForegroundColor',C.white);
            set(btnCheby, 'BackgroundColor',C.pink,'ForegroundColor',C.text);
        else
            set(btnButter,'BackgroundColor',C.butter,'ForegroundColor',C.text);
            set(btnCheby, 'BackgroundColor',C.plum,'ForegroundColor',C.white);
        end
        % Restore normal layout
        for k=1:4, set(ax(k),'Position',normalPos{k}); end
        generateSignal();
    end

%% ── toggleCompare ────────────────────────────────────────
    function toggleCompare()
        state.compare = ~state.compare;
        if state.compare
            set(btnCompare,'BackgroundColor',C.plum,'ForegroundColor',C.white);
            set(btnButter,'BackgroundColor',C.butter,'ForegroundColor',C.text);
            set(btnCheby, 'BackgroundColor',C.pink,  'ForegroundColor',C.text);
            for k=1:4, set(ax(k),'Position',comparePos{k}); end
        else
            set(btnCompare,'BackgroundColor',[0.82 0.70 0.88],'ForegroundColor',C.text);
            for k=1:4, set(ax(k),'Position',normalPos{k}); end
        end
        generateSignal();
    end

%% ── buildSignal (shared helper) ─────────────────────────
    function [rawSig, t, Fs, dur] = buildSignal()
        Fs  = 256; dur = 4;
        t   = 0:1/Fs:dur-1/Fs;
        nAmp = get(slNoise,'Value');
        idx  = get(ddSignal,'Value');

        switch state.mode
            case 'mood'
                freqs  = [10 20 6 8 25 2];
                labels = {'Happy','Stressed','Sleepy','Calm','Anxious','Deep Sleep'};
                f0  = freqs(idx);
                sig = sin(2*pi*f0*t) + 0.4*sin(2*pi*f0*1.5*t);
                state.label = labels{idx};
            case 'sleep'
                labels = {'Well Rested','A Little Tired','Sleep Deprived','Zombie Mode'};
                state.label = labels{idx};
                switch idx
                    case 1, sig=1.2*sin(2*pi*2*t)+0.2*sin(2*pi*1*t); nAmp=nAmp*0.15;
                    case 2, sig=sin(2*pi*6*t)+0.5*sin(2*pi*2*t);     nAmp=nAmp*0.5;
                    case 3, sig=0.5*sin(2*pi*2*t)+sin(2*pi*18*t);    nAmp=nAmp*1.1;
                    case 4, sig=0.2*sin(2*pi*2*t);                    nAmp=nAmp*2.0;
                end
            case 'focus'
                labels = {'Deep Focus','Study Mode','Daydreaming','Overwhelmed'};
                state.label = labels{idx};
                switch idx
                    case 1, sig=sin(2*pi*18*t)+0.3*sin(2*pi*20*t);
                    case 2, sig=sin(2*pi*10*t)+0.6*sin(2*pi*18*t);
                    case 3, sig=sin(2*pi*5*t)+0.4*sin(2*pi*7*t);
                    case 4, sig=sin(2*pi*40*t)+0.7*sin(2*pi*35*t);
                end
        end
        rawSig = sig + nAmp*randn(size(t));
    end

%% ── designFilter (shared helper) ────────────────────────
    function [b, a, fName, n] = designFilter(type, Fs)
        Wp=30/(Fs/2); Ws=50/(Fs/2); Rp=3; Rs=40;
        if strcmp(type,'butter')
            [n,Wn]=buttord(Wp,Ws,Rp,Rs); [b,a]=butter(n,Wn,'low');
            fName=sprintf('Butterworth (order %d)',n);
        else
            [n,Wn]=cheb1ord(Wp,Ws,Rp,Rs); [b,a]=cheby1(n,Rp,Wn,'low');
            fName=sprintf('Chebyshev I (order %d)',n);
        end
    end

%% ── generateSignal ───────────────────────────────────────
    function generateSignal()
        if state.compare
            runCompare();
        else
            runNormal();
        end
    end

%% ── runNormal ────────────────────────────────────────────
    function runNormal()
        [rawSig, t, Fs, dur] = buildSignal();
        [b, a, fName, ~]     = designFilter(state.filterType, Fs);
        filtSig = filter(b,a,rawSig);

        % SNR
        snr = 10*log10(var(filtSig)/(var(rawSig-filtSig)+1e-9));
        snr = min(max(snr,-5),40);

        % Dominant band
        N=length(rawSig); f=(0:N/2-1)*(Fs/N);
        Y=abs(fft(filtSig))/N; [~,im]=max(Y(1:N/2)); df=f(im);
        band = freqBand(df);

        % Score cards
        set(scoreCards(1),'String',sprintf('%.1f dB',snr));
        set(scoreCards(2),'String',band);
        set(scoreCards(3),'String',fName);
        set(scoreCards(4),'String',state.label);
        if snr>20, sc=C.mint; elseif snr>5, sc=C.butter; else, sc=C.pink; end
        set(scoreCards(1),'BackgroundColor',sc);
        set(txtVerdict,'String',sprintf('%s\n%s band  |  %.1f Hz\nSNR: %.1f dB', ...
            state.label, band, df, snr));

        % Plot 1 — Raw
        cla(ax(1));
        plot(ax(1),t,rawSig,'Color',C.rose,'LineWidth',1.0);
        xlabel(ax(1),'Time (s)','FontSize',8);
        ylabel(ax(1),'Amplitude','FontSize',8);
        title(ax(1),['Raw — ' state.label],'FontSize',9,'FontWeight','bold','Color',C.text);
        xlim(ax(1),[0 dur]); grid(ax(1),'on');
        set(ax(1),'Color',C.white,'GridColor',C.grid);

        % Plot 2 — Filtered
        cla(ax(2));
        plot(ax(2),t,rawSig,'Color',[C.pink 0.3],'LineWidth',0.7); hold(ax(2),'on');
        plot(ax(2),t,filtSig,'Color',C.plum,'LineWidth',1.5);
        legend(ax(2),{'Raw','Filtered'},'FontSize',8,'Location','northeast', ...
            'Color',C.panel,'TextColor',C.text,'EdgeColor',C.pink);
        xlabel(ax(2),'Time (s)','FontSize',8);
        title(ax(2),['Filtered — ' fName],'FontSize',9,'FontWeight','bold','Color',C.text);
        xlim(ax(2),[0 dur]); grid(ax(2),'on');
        set(ax(2),'Color',C.white,'GridColor',C.grid);

        % Plot 3 — Spectrum before
        Yraw=abs(fft(rawSig))/N;
        cla(ax(3)); hold(ax(3),'on');
        bandShade(ax(3), max(Yraw)*1.1);
        area(ax(3),f,Yraw(1:N/2),'FaceColor',C.pink,'FaceAlpha',0.55,'EdgeColor',C.rose,'LineWidth',0.8);
        xline(ax(3),df,'Color',C.plum,'LineWidth',1.8,'LineStyle','--');
        text(df+0.5,max(Yraw)*0.7,sprintf('%.0f Hz',df), ...
            'Parent',ax(3),'FontSize',8,'Color',C.plum,'FontWeight','bold');
        xlabel(ax(3),'Frequency (Hz)','FontSize',8);
        ylabel(ax(3),'|X(f)|','FontSize',8);
        title(ax(3),'Spectrum — Before Filter','FontSize',9,'FontWeight','bold','Color',C.text);
        xlim(ax(3),[0 60]); ylim(ax(3),[0 max(Yraw)*1.15+0.001]);
        grid(ax(3),'on'); set(ax(3),'Color',C.white,'GridColor',C.grid);

        % Plot 4 — Spectrum after
        Yfilt=abs(fft(filtSig))/N;
        cla(ax(4)); hold(ax(4),'on');
        bandShade(ax(4), max(Yfilt)*1.1);
        area(ax(4),f,Yfilt(1:N/2),'FaceColor',C.mint,'FaceAlpha',0.6,'EdgeColor',[0.3 0.7 0.5],'LineWidth',0.8);
        xlabel(ax(4),'Frequency (Hz)','FontSize',8);
        ylabel(ax(4),'|X(f)|','FontSize',8);
        title(ax(4),'Spectrum — After Filter','FontSize',9,'FontWeight','bold','Color',C.text);
        xlim(ax(4),[0 60]); ylim(ax(4),[0 max(Yfilt)*1.15+0.001]);
        grid(ax(4),'on'); set(ax(4),'Color',C.white,'GridColor',C.grid);

        drawnow;
    end

%% ── runCompare ───────────────────────────────────────────
    function runCompare()
        [rawSig, t, Fs, dur] = buildSignal();

        % Build both filters
        [bB,aB,~,nB] = designFilter('butter',Fs);
        [bC,aC,~,nC] = designFilter('cheby', Fs);
        filtB = filter(bB,aB,rawSig);
        filtC = filter(bC,aC,rawSig);

        snrB = min(max(10*log10(var(filtB)/(var(rawSig-filtB)+1e-9)),-5),40);
        snrC = min(max(10*log10(var(filtC)/(var(rawSig-filtC)+1e-9)),-5),40);

        % Frequency response (512 points)
        [HB,wB] = freqz(bB,aB,512,Fs);
        [HC,wC] = freqz(bC,aC,512,Fs);

        % Score cards — show compare info
        set(scoreCards(1),'String',sprintf('B:%.1fdB  C:%.1fdB',snrB,snrC), ...
            'BackgroundColor',[0.82 0.70 0.88]);
        set(scoreCards(2),'String',freqBand(dominantHz(filtB,Fs)));
        set(scoreCards(3),'String','Butter vs Cheby');
        set(scoreCards(4),'String',state.label);
        set(txtVerdict,'String',sprintf('%s\nButter SNR: %.1f dB\nCheby  SNR: %.1f dB', ...
            state.label, snrB, snrC));

        % ── Top-left: Butterworth filtered vs raw ──────────
        cla(ax(1)); hold(ax(1),'on');
        plot(ax(1),t,rawSig,'Color',[C.pink 0.35],'LineWidth',0.7);
        plot(ax(1),t,filtB,'Color',C.plum,'LineWidth',1.6);
        legend(ax(1),{'Raw',sprintf('Butter ord %d',nB)},'FontSize',7.5, ...
            'Location','northeast','Color',C.panel,'TextColor',C.text,'EdgeColor',C.pink);
        xlabel(ax(1),'Time (s)','FontSize',8);
        ylabel(ax(1),'Amplitude','FontSize',8);
        title(ax(1),sprintf('Butterworth  |  SNR %.1f dB',snrB), ...
            'FontSize',9,'FontWeight','bold','Color',C.plum);
        xlim(ax(1),[0 dur]); grid(ax(1),'on');
        set(ax(1),'Color',C.white,'GridColor',C.grid);

        % ── Top-right: Chebyshev filtered vs raw ───────────
        cla(ax(2)); hold(ax(2),'on');
        plot(ax(2),t,rawSig,'Color',[C.pink 0.35],'LineWidth',0.7);
        plot(ax(2),t,filtC,'Color',C.teal,'LineWidth',1.6);
        legend(ax(2),{'Raw',sprintf('Cheby ord %d',nC)},'FontSize',7.5, ...
            'Location','northeast','Color',C.panel,'TextColor',C.text,'EdgeColor',C.pink);
        xlabel(ax(2),'Time (s)','FontSize',8);
        ylabel(ax(2),'Amplitude','FontSize',8);
        title(ax(2),sprintf('Chebyshev I  |  SNR %.1f dB',snrC), ...
            'FontSize',9,'FontWeight','bold','Color',C.teal);
        xlim(ax(2),[0 dur]); grid(ax(2),'on');
        set(ax(2),'Color',C.white,'GridColor',C.grid);

        % ── Bottom-left: Butterworth frequency response ─────
        cla(ax(3)); hold(ax(3),'on');
        % Passband / stopband shading
        patch(ax(3),[0 30 30 0],[-80 -80 3 3],[0.7 1 0.8], ...
            'FaceAlpha',0.18,'EdgeColor','none');
        patch(ax(3),[50 Fs/2 Fs/2 50],[-80 -80 3 3],[1 0.7 0.7], ...
            'FaceAlpha',0.18,'EdgeColor','none');
        xline(ax(3),30,'--','Color',[0.5 0.5 0.5],'LineWidth',1,'Alpha',0.7);
        xline(ax(3),50,'--','Color',[0.5 0.5 0.5],'LineWidth',1,'Alpha',0.7);
        text(15,-10,'Pass','Parent',ax(3),'FontSize',8,'Color',[0.3 0.6 0.4], ...
            'HorizontalAlignment','center');
        text(60,-10,'Stop','Parent',ax(3),'FontSize',8,'Color',[0.7 0.3 0.3], ...
            'HorizontalAlignment','center');
        plot(ax(3),wB,20*log10(abs(HB)+1e-12),'Color',C.plum,'LineWidth',2);
        xlabel(ax(3),'Frequency (Hz)','FontSize',8);
        ylabel(ax(3),'Magnitude (dB)','FontSize',8);
        title(ax(3),sprintf('Butterworth Freq Response (order %d)',nB), ...
            'FontSize',9,'FontWeight','bold','Color',C.plum);
        xlim(ax(3),[0 Fs/2]); ylim(ax(3),[-80 5]);
        grid(ax(3),'on'); set(ax(3),'Color',C.white,'GridColor',C.grid);

        % ── Bottom-right: Chebyshev frequency response ──────
        cla(ax(4)); hold(ax(4),'on');
        patch(ax(4),[0 30 30 0],[-80 -80 3 3],[0.7 1 0.8], ...
            'FaceAlpha',0.18,'EdgeColor','none');
        patch(ax(4),[50 Fs/2 Fs/2 50],[-80 -80 3 3],[1 0.7 0.7], ...
            'FaceAlpha',0.18,'EdgeColor','none');
        xline(ax(4),30,'--','Color',[0.5 0.5 0.5],'LineWidth',1,'Alpha',0.7);
        xline(ax(4),50,'--','Color',[0.5 0.5 0.5],'LineWidth',1,'Alpha',0.7);
        text(15,-10,'Pass','Parent',ax(4),'FontSize',8,'Color',[0.3 0.6 0.4], ...
            'HorizontalAlignment','center');
        text(60,-10,'Stop','Parent',ax(4),'FontSize',8,'Color',[0.7 0.3 0.3], ...
            'HorizontalAlignment','center');
        plot(ax(4),wC,20*log10(abs(HC)+1e-12),'Color',C.teal,'LineWidth',2);
        xlabel(ax(4),'Frequency (Hz)','FontSize',8);
        ylabel(ax(4),'Magnitude (dB)','FontSize',8);
        title(ax(4),sprintf('Chebyshev I Freq Response (order %d)',nC), ...
            'FontSize',9,'FontWeight','bold','Color',C.teal);
        xlim(ax(4),[0 Fs/2]); ylim(ax(4),[-80 5]);
        grid(ax(4),'on'); set(ax(4),'Color',C.white,'GridColor',C.grid);

        drawnow;
    end

%% ── Helpers ──────────────────────────────────────────────
    function b = freqBand(df)
        if     df < 4,  b = 'Delta';
        elseif df < 8,  b = 'Theta';
        elseif df < 13, b = 'Alpha';
        elseif df < 30, b = 'Beta';
        else,            b = 'Gamma';
        end
    end

    function df = dominantHz(sig, Fs)
        N  = length(sig);
        f  = (0:N/2-1)*(Fs/N);
        Y  = abs(fft(sig))/N;
        [~,im] = max(Y(1:N/2));
        df = f(im);
    end

    function bandShade(axh, ymax)
        edges = [0 4;4 8;8 13;13 30;30 60];
        cols  = {[0.7 0.7 1],[1 0.85 0.6],[0.7 1 0.8],[1 0.7 0.75],[0.88 0.7 1]};
        names = {'delta','theta','alpha','beta','gamma'};
        for i = 1:5
            x1=edges(i,1); x2=min(edges(i,2),60);
            patch(axh,[x1 x2 x2 x1],[0 0 ymax ymax], ...
                cols{i},'FaceAlpha',0.14,'EdgeColor','none');
            text((x1+x2)/2,ymax*0.90,names{i},'Parent',axh, ...
                'FontSize',7,'HorizontalAlignment','center','Color',C.muted);
        end
    end

%% ── Save ─────────────────────────────────────────────────
    function saveReport()
        [fn,fp] = uiputfile('*.png','Save Report...');
        if fn==0, return; end
        exportgraphics(fig,fullfile(fp,fn),'Resolution',150);
        msgbox(['Saved: ' fullfile(fp,fn)],'Done!');
    end

%% ── Reset ────────────────────────────────────────────────
    function resetAll()
        state.compare = false;
        set(btnCompare,'BackgroundColor',[0.82 0.70 0.88],'ForegroundColor',C.text);
        for k = 1:4
            set(ax(k),'Position',normalPos{k});
            cla(ax(k));
            text(0.5,0.5,'— press Generate —','Parent',ax(k), ...
                'Units','normalized','HorizontalAlignment','center', ...
                'Color',C.muted,'FontSize',9);
        end
        for k = 1:4
            set(scoreCards(k),'String','——','BackgroundColor',C.white);
        end
        set(txtVerdict,'String','Press Generate!');
    end

%% ── Launch ───────────────────────────────────────────────
setMode('mood');
setFilter('butter');

end
