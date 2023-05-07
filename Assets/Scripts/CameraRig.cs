using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRig : MonoBehaviour
{
    public List<Transform> point_of_view_list = new List<Transform>();
    public float rotation_speed = 0.5f;
    public float vertical_offset = 1.0f;


    private int current_pov = 0;
    private Vector3 euler_angles = Vector3.zero;
    private Vector3 initial_euler_angles= Vector3.zero;

    private void Start()
    {
        initial_euler_angles = euler_angles = transform.eulerAngles;
    }

    void Update()
    {
        if (Input.GetButtonDown("Fire1")) current_pov++;
        if (Input.GetButtonDown("Fire2")) current_pov--;
        if (Input.GetButtonDown("Fire3")) euler_angles = initial_euler_angles;

        if (current_pov < 0) current_pov = point_of_view_list.Count - 1;
        if (current_pov > point_of_view_list.Count - 1) current_pov = 0;

        transform.position = point_of_view_list[current_pov].position + Vector3.up*vertical_offset;

        euler_angles.y += Input.GetAxis("Horizontal") * rotation_speed * Time.deltaTime;
        euler_angles.x += Input.GetAxis("Vertical") * rotation_speed * Time.deltaTime;

        transform.eulerAngles = euler_angles;
    }
}
