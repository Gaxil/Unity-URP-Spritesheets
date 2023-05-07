using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FlickeringLights : MonoBehaviour
{
    public GameObject Light1;
    public GameObject Light2;
    public float FlickeringSpeed = 1.0f;

    // Update is called once per frame
    void Update()
    {
        float relative_time = Time.time * FlickeringSpeed;

        if (relative_time % 1.0f<0.5f)
        {
            Light1.SetActive(true);
            Light2.SetActive(false);
        } else
        {
            Light1.SetActive(false);
            Light2.SetActive(true);
        } 
    }
}
