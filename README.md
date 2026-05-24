# 🧠 BrainWave Studio

**An interactive MATLAB GUI for brainwave simulation, digital filtering, and mental state visualisation.**

Built as a Signals & Systems project at Ziauddin University — simulates EEG-style brainwave signals across three mental state modes, applies classical IIR filters in real time, and lets you compare Butterworth vs Chebyshev I side by side.

---

## ✨ Features

| Feature | Details |
|---|---|
| **3 Mental State Modes** | Mood Check · Sleep Check · Focus Check |
| **14 Brain States** | Happy, Stressed, Sleepy, Deep Focus, Zombie Mode, and more |
| **2 Digital Filters** | Butterworth · Chebyshev Type I (both lowpass, auto-designed) |
| **Compare Filters Mode** | Side-by-side time-domain output + frequency response plots |
| **Live Noise Control** | Slider from 0.1 → 1.8 amplitude |
| **4 Real-Time Plots** | Raw signal · Filtered signal · FFT before · FFT after |
| **SNR Score Card** | Colour-coded: green > 20 dB · yellow 5–20 dB · pink < 5 dB |
| **Brain Verdict Box** | Dominant band, frequency, and SNR in plain language |
| **Save Report** | Exports full GUI as a PNG (150 dpi) |

---

## 🖥️ Screenshots

> *Normal mode (left) and Compare Filters mode (right)*
>
> *(Add your screenshots here after running the GUI)*

---

## 🚀 How to Run

### MATLAB Desktop
```
1. Open MATLAB
2. Open BrainWaveStudio.m
3. Press Run (F5) or type BrainWaveStudio in the Command Window
```

### MATLAB Online
```
1. Upload BrainWaveStudio.m to MATLAB Online
2. Go to Home → Layout → uncheck "Show Figure Docked"
3. Run the file — the GUI opens in its own window
```

---

## 🎛️ How to Use

1. **Choose a Mode** — Mood Check, Sleep Check, or Focus Check
2. **Select a Brain State** from the dropdown
3. **Pick a Filter** — Butterworth, Chebyshev I, or hit **Compare Both ⇄**
4. **Adjust Noise** with the slider
5. **Click Generate Signal** to render all plots
6. **Save Report** to export the GUI as a PNG

### Compare Filters Mode
Hitting **Compare Both ⇄** switches the layout to show:
- **Top row** — filtered time-domain output for each filter
- **Bottom row** — frequency response (magnitude in dB) for each filter, with passband/stopband shading

This makes it easy to see how the filters differ in roll-off, ripple, and their effect on the signal.

---

## 🧪 Signal & Filter Parameters

```
Sampling Rate (Fs)  : 256 Hz
Signal Duration     : 4 seconds
Samples (N)         : 1024

Filter Type         : Lowpass IIR
Passband edge (Wp)  : 30 Hz  |  Rp = 3 dB
Stopband edge (Ws)  : 50 Hz  |  Rs = 40 dB
Order               : Auto-calculated (buttord / cheb1ord)
```

### EEG Band Reference

| Band | Frequency | Mental States Simulated |
|---|---|---|
| **Delta** | 0–4 Hz | Deep Sleep, Well Rested |
| **Theta** | 4–8 Hz | Sleepy, Daydreaming, Tired |
| **Alpha** | 8–13 Hz | Happy, Calm, Study Mode |
| **Beta** | 13–30 Hz | Stressed, Focused, Anxious |
| **Gamma** | 30+ Hz | Overwhelmed |

---

## 📁 Files

```
BrainWave-Studio/
├── BrainWaveStudio.m   ← Main GUI (run this)
└── README.md
```

---

## 🔧 Requirements

- MATLAB R2020b or later
- Signal Processing Toolbox (for `butter`, `cheby1`, `buttord`, `cheb1ord`, `freqz`, `filter`)

---

## 📚 Reference

> Baghdadi, G. et al. (2022). *Review of EEG Signals Approaches for Mental Stress Assessment.*
> PMC — [https://pmc.ncbi.nlm.nih.gov/articles/PMC9749579/](https://pmc.ncbi.nlm.nih.gov/articles/PMC9749579/)

---

## 👩‍💻 Author

**Daniya** — Semester IV, Ziauddin University
Signals & Systems — MATLAB GUI Project

---

## 📄 License

MIT License — free to use, modify, and share with attribution.
