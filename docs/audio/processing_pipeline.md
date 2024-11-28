# Audio Processing Pipeline

## 1. Noise Reduction
- **Goal**: Remove background noise like hums, hisses, or environmental sounds.
- **Step**:
  - Identify noise-only regions in the audio.
  - Create a noise profile from these regions.
  - Apply noise reduction to the entire track.

---

## 2. Equalization (EQ)
- **Goal**: Balance frequencies for clarity and tonal enhancement.
- **Step**:
  - Use a low-cut filter to remove sub-bass rumble (<80 Hz).
  - Reduce muddiness in the low-mids (200–400 Hz).
  - Boost presence and clarity (3–5 kHz).
  - Add brightness to high frequencies (10–12 kHz).

---

## 3. Compression
- **Goal**: Smooth out volume inconsistencies and add cohesion to the audio.
- **Step**:
  - Apply a compressor to reduce dynamic range.
  - Set attack and release to preserve transients and ensure smooth recovery.
  - Adjust ratio and threshold to achieve a balanced sound.

---

## 4. De-Esser (Optional)
- **Goal**: Reduce sibilance ("s" and "sh" sounds).
- **Step**:
  - Identify the sibilant frequency range (5–10 kHz).
  - Apply a narrow EQ dip or dynamic EQ to tame harshness.

---

## 5. Stereo Widening and Harmonization
- **Goal**: Create a fuller, richer sound by duplicating and modifying the audio.
- **Step**:
  - Duplicate the track three times:
    1. Pan one duplicate left (~40L).
    2. Pan one duplicate right (~40R).
    3. Pitch-shift one duplicate up an octave.
  - Add slight delays to the panned duplicates for depth.
  - Adjust gain for balance and merge all tracks back together.

---

## 6. Reverb
- **Goal**: Add spatial depth and atmosphere to the audio.
- **Step**:
  - Apply convolution or algorithmic reverb.
  - Adjust room size, decay, and wet/dry mix for a natural effect.

---

## 7. Limiting and Normalization
- **Goal**: Prevent clipping and ensure consistent loudness.
- **Step**:
  - Use a limiter to cap the peaks at -1 dB.
  - Normalize the overall volume to meet desired levels (e.g., -16 LUFS).

---

## 8. Artifact Generation (Optional)
- **Goal**: Output useful artifacts for further production.
- **Step**:
  - Extract MIDI from the processed audio.
  - Generate a spectrogram for harmonic analysis.
  - Separate vocals and stems using source separation tools.
  - Export tempo and beat timing data.
  - Save all artifacts into a dedicated folder for producers.