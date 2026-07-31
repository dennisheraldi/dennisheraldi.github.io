---
layout: post
title: 'My First Overseas Trip: ICAICTA 2024 in Singapore'
description: 'Presenting my final project as a paper at ICAICTA 2024, winning a Best Paper Award, and seeing Singapore for the first time.'
date: 2025-12-14
tags: [travel, research, conference, personal]
---

In September 2024 I left Indonesia for the first time. The reason was ICAICTA 2024, the 11th International Conference on Advanced Informatics: Concepts, Theory and Applications, where I presented the paper that came out of my final project at ITB.

## The conference

ICAICTA is organized jointly by the Department of Computer Science and Engineering at Toyohashi University of Technology and the School of Electrical Engineering and Informatics at Institut Teknologi Bandung. The 2024 edition was hosted by the Electrical and Computer Engineering department at the National University of Singapore, so most people there were Japanese, Indonesian, or Singaporean researchers.

Getting the paper accepted was the part I had been anxious about for months. Presenting it turned out to be the easier half.

## The research

The paper is **"Effective Intended Sarcasm Detection Using Fine-tuned Llama 2 Large Language Models"**, written with my supervisor, Bu Fariska.

Sarcasm is hard for a model because the intended meaning contradicts the words on the page. I fine-tuned Meta's Llama 2 on 21,599 samples using Parameter Efficient Fine-tuning (PEFT) with Quantized Low Rank Adaptation (QLoRA), which is what made the training fit on the hardware I had. The results:

- **0.6867 F1** on sarcasm detection
- **0.90 accuracy** on pairwise sarcasm identification

Both were ahead of the earlier work we compared against on the same task.

[Read the full paper on IEEE Xplore](https://ieeexplore.ieee.org/document/10763281)

---

## Day 1: Arrival (September 27)

I landed at Changi and went straight to my hotel in Chinatown. Walking around there that evening was a good first impression of the city: lanterns over the street, food everywhere, still busy late at night.

![Chinatown at night](/public/img/icaicta2024/Chinatown.jpeg)
_Chinatown on my first night in Singapore_

---

## Day 2: Presenting (September 28)

I presented on the first day of the conference: methodology, results, and where sarcasm detection actually helps in sentiment analysis.

![Presenting my paper](/public/img/icaicta2024/Presentation.jpeg)
_Presenting "Effective Intended Sarcasm Detection Using Fine-tuned Llama 2 Large Language Models"_

The questions afterwards were mostly about how the dataset was labeled and whether the approach would hold up on social media text. Nerve-wracking, but the kind of discussion I had hoped for.

That evening a group of us went to **Redhouse Seafood at Clarke Quay**. Good food, and much easier conversation than the formal sessions.

![Dinner at Redhouse Seafood](/public/img/icaicta2024/Dinner.jpeg)
_Dinner with other attendees at Redhouse Seafood, Clarke Quay_

---

## Day 3: Best Paper Award (September 29)

At the closing ceremony my paper was named **one of the four Best Paper Award winners**. I had not expected it at all.

![Best Paper Award ceremony](/public/img/icaicta2024/ICAICTA%20Best%20Paper.jpeg)
_The Best Paper Award announcement at ICAICTA 2024_

A lot of the credit goes to Bu Fariska, who kept pushing the work in a better direction whenever I was ready to settle for what I already had.

Afterwards there were group photos. I met Melisa, a Computer Science student at NTU who is also Indonesian.

![Group photo with Melisa, Acho, and Kak Akeyla](/public/img/icaicta2024/Group%20Photo%20with%20Melisa.jpeg)
_With Melisa from NTU and other Indonesian attendees_

![All participants at NUS Engineering](/public/img/icaicta2024/ICAICTA%20participant.jpeg)
_ICAICTA 2024 participants at the NUS Engineering sign_

---

## Day 4: Looking around (September 30)

I had one day left before flying home, so a few friends from the conference and Bu Ayu, my lecturer from ITB, went around the city with me.

**CHIJMES** was the one that stuck with me: a restored 19th-century convent now full of restaurants, Gothic architecture sitting right under the modern skyline.

![CHIJMES](/public/img/icaicta2024/Chijmes.jpeg)
_CHIJMES, with friends from the conference_

---

## Photo dump

A few more places from the rest of the trip:

<div class="photo-carousel">
  <div class="carousel-track">
    <figure class="carousel-item">
      <img src="/public/img/icaicta2024/carousel/garden%20by%20the%20bay%20rhapsody.jpeg" alt="Garden by the Bay Rhapsody" loading="lazy">
      <figcaption>Garden by the Bay Rhapsody</figcaption>
    </figure>
    <figure class="carousel-item">
      <img src="/public/img/icaicta2024/carousel/merlion%20park.jpeg" alt="Merlion Park" loading="lazy">
      <figcaption>The iconic Merlion at Marina Bay</figcaption>
    </figure>
    <figure class="carousel-item">
      <img src="/public/img/icaicta2024/carousel/Rain%20vortex%20Jewel.jpeg" alt="Rain Vortex at Jewel Changi" loading="lazy">
      <figcaption>Rain Vortex at Jewel Changi Airport</figcaption>
    </figure>
    <figure class="carousel-item">
      <img src="/public/img/icaicta2024/carousel/spectra%20marina%20bay%20sands.jpeg" alt="Spectra at Marina Bay Sands" loading="lazy">
      <figcaption>Spectra light show at Marina Bay Sands</figcaption>
    </figure>
    <figure class="carousel-item">
      <img src="/public/img/icaicta2024/carousel/universal%20studio%20sentosa.jpeg" alt="Universal Studios Sentosa" loading="lazy">
      <figcaption>Universal Studios Singapore at Sentosa</figcaption>
    </figure>
  </div>
</div>

---

## Looking back

More than a year on, the award is not really the part I think about. It was the first time I had to find my way around a foreign city alone, and the first time I had to explain my work to people who had no reason to be kind about it. Both were more useful than the certificate.
