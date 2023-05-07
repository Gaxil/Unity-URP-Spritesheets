using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class AutoRotate : MonoBehaviour
{
    public Vector3 rotation_speed = Vector3.zero;
    public Vector3 initial_rotation;

    // Update is called once per frame
    void Update()
    {
        float rotationX = Mathf.Deg2Rad * initial_rotation.x + Time.time * rotation_speed.x * Mathf.PI * 2.0f * 0.016f;
        float rotationY = Mathf.Deg2Rad * initial_rotation.y + Time.time * rotation_speed.y * Mathf.PI * 2.0f * 0.016f;
        float rotationZ = Mathf.Deg2Rad * initial_rotation.z + Time.time * rotation_speed.z * Mathf.PI * 2.0f * 0.016f;

        transform.localRotation = quaternion.EulerYZX(rotationX, rotationY, rotationZ);  
    }
}
