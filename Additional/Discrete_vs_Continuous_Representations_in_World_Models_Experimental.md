# Discrete vs. Continuous Representations in World Models: Pros and Cons

Oct 20, 2026 · @Mircea Petrache

Discrete latents help most with branching dynamics, capacity-limited rollouts and adaptation; they cost information, gradient quality and codebook efficiency. Bracketed numbers point to the references at the end.

## Pros

**1. A discrete choice over futures captures branching dynamics that regression averages away.** A regression predictor outputs the mean of the possible next states, which can be no real state at all. In a JEPA world model on OGBench mazes, planning over single-predictor rollouts reached 0.02–0.09 success, while K hard-assigned predictor heads reached up to 0.85, ahead of deterministic, soft-mixture and continuous variational predictors on every task \[1\]. A learned discrete chance code likewise lifted 2048 scores from about 300k (deterministic MuZero) to about 500k \[2\].

**2. One-hot latents give more accurate multi-step rollouts when the world model is small relative to the world.** With the encoder swapped and the transition model held fixed, one-hot VQ latents tracked the true state distribution over 30-step rollouts better than dense or sparse continuous latents, especially on rare transitions \[3\]. The advantage disappears once the world model is large enough. Snapped codebook vectors carrying the same information did much worse than one-hot indices, so the benefit comes from sparse binary encoding rather than discreteness alone \[3\]. Replacing Gaussian with categorical latents in Dreamer also improved most Atari games \[4\].

**3. Sparse discrete latents adapt faster to change and resist distribution shift.** In continual RL with layouts randomized periodically, reward per layout was 674 vs. 382 (crossing) and 1324 vs. 866 (door-key) for one-hot vs. dense continuous latents \[3\]. Adding discrete VQ tokens to a ViT's input improved robustness by up to 12% across seven ImageNet benchmarks with no loss in clean accuracy \[5\].

**4. Discrete codes can work well even for continuous control, if they keep a metric.** A reconstruction-free world model with FSQ codes trained by cross-entropy beat continuous regression variants and was competitive with TD-MPC2 and DreamerV3 under MPPI planning \[6\]. Codebook vectors, which preserve ordering between codes, outperformed one-hot encodings in this setting \[6\].

## Cons

**1. Quantization throws away information.** With the same transformer and loss, a VQ tokenizer reconstructed images much worse than a continuous KL tokenizer, and generation FID followed: 7.82 vs. 3.50 \[7\]. In a latent-action world model trained on in-the-wild video, vector-quantized actions failed to capture the complexity of real actions, while sparse or noisy continuous actions succeeded \[8\].

**2. Straight-through gradients cost real quality.** Keeping the quantizer fixed and only replacing the straight-through estimator with a gradient that carries angle and magnitude improved a VQGAN's reconstruction FID from 5.0 to 1.6, with gains in all 11 VQ-VAE setups tested \[9\].

**3. Learned codebooks underuse their codes as they grow.** A VQ codebook's usage drops beyond about 2^11 codes, and reconstruction quality peaks there, while a fixed FSQ grid uses nearly all 2^16 codes with no extra losses \[10\]. A standard VQGAN used only 2% of its codebook \[9\].

**4. Discreteness is not needed for autoregressive modeling, and can hurt.** Continuous tokens with a per-token diffusion loss beat discrete tokens with cross-entropy in every autoregressive configuration tested, and even on the same VQ tokenizer (FID 7.82 vs. 8.79) \[7\]. Cross-entropy remains simpler to train and slots into LLM-style stacks.

**5. The right discrete encoding depends on the domain.** One-hot beat codebook vectors in a gridworld \[3\], while codebook vectors beat one-hot in continuous control \[6\], so a poor encoding choice can erase the benefits above.

## Combining both

The hybrid with the clearest support keeps a continuous state for memory and precision and uses a discrete choice only for stochastic branching. Removing either the deterministic or the stochastic path of a latent dynamics model hurt planning \[11\]. Within that design, a categorical stochastic part beat a Gaussian one \[4\], and discrete heads on top of a continuous JEPA state beat continuous stochastic prediction \[1\].

No published experiment yet compares a fully discrete JEPA state space with a continuous one under otherwise identical conditions; \[1\], \[6\] and \[8\] are the closest.

## References

1. Song et al. [MoP-JEPA: Hard-Assigned Predictor Mixtures for Stochastic JEPA World Models](https://arxiv.org/abs/2607.05238). arXiv 2607.05238, 2026.
2. Antonoglou et al. [Planning in Stochastic Environments with a Learned Model](https://iclr.cc/virtual/2022/spotlight/6833). ICLR 2022.
3. Meyer, White & Machado. [Harnessing Discrete Representations for Continual Reinforcement Learning](https://arxiv.org/abs/2312.01203). RLC 2024.
4. Hafner et al. [Mastering Atari with Discrete World Models](https://arxiv.org/abs/2010.02193). ICLR 2021.
5. Mao et al. [Discrete Representations Strengthen Vision Transformer Robustness](https://arxiv.org/abs/2111.10493). ICLR 2022.
6. Scannell et al. [Discrete Codebook World Models for Continuous Control](https://arxiv.org/abs/2503.00653). ICLR 2025.
7. Li et al. [Autoregressive Image Generation without Vector Quantization](https://arxiv.org/abs/2406.11838). NeurIPS 2024.
8. Garrido et al. [Learning Latent Action World Models in the Wild](https://arxiv.org/abs/2601.05230). ICML 2026.
9. Fifty et al. [Restructuring Vector Quantization with the Rotation Trick](https://arxiv.org/abs/2410.06424). ICLR 2025.
10. Mentzer et al. [Finite Scalar Quantization: VQ-VAE Made Simple](https://arxiv.org/abs/2309.15505). ICLR 2024.
11. Hafner et al. [Learning Latent Dynamics for Planning from Pixels](https://arxiv.org/abs/1811.04551). ICML 2019.
