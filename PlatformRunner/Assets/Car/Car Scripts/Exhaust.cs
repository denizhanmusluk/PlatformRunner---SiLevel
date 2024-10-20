using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Exhaust : MonoBehaviour
{
    public List<ParticleSystem> exhaustParticles;
    float factor = 4f;
    public void ExhaustGas(float rpm)
    {
        foreach (var ex in exhaustParticles)
        {
            var main = ex.main;
            var emission = ex.emission;
            main.startSpeed = 0.25f * (1f + factor * rpm / 7000f);
            emission.rateOverTime = 15f * (1f + factor * rpm / 7000f);
        }
    }
}
