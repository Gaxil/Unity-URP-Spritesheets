using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class RandomLight: MonoBehaviour
{

    public float speed = 1.0f;
    public float variation_intensity = 0.5f;
    
    private float initial_intensity;
    private Light local_light;

    private void Start()
    {
        local_light = GetComponent<Light>();
        initial_intensity = local_light.intensity;
    }

    // Update is called once per frame
    void Update()
    {
        local_light.intensity = initial_intensity + noise.snoise(new Vector2(Time.time * speed, 0.0f)) * variation_intensity;
    }
}
