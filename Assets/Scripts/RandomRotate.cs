using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class RandomRotate : MonoBehaviour
{

    public float speed = 1.0f;
    public Vector3 random_rotation_intensity = Vector3.zero;
    public Vector3 initial_rotation;

    // Update is called once per frame
    void Update()
    {
        float rotationX = Mathf.Deg2Rad * initial_rotation.x + (noise.snoise(new Vector2(Time.time * speed, 0.0f ))) * Mathf.Deg2Rad * random_rotation_intensity.x;
        float rotationY = Mathf.Deg2Rad * initial_rotation.y + (noise.snoise(new Vector2(Time.time * speed, 10.0f))) * Mathf.Deg2Rad * random_rotation_intensity.y;
        float rotationZ = Mathf.Deg2Rad * initial_rotation.z + (noise.snoise(new Vector2(Time.time * speed, 20.0f))) * Mathf.Deg2Rad * random_rotation_intensity.z;

        transform.localRotation = quaternion.EulerYZX(rotationX, rotationY, rotationZ);  
    }
}
