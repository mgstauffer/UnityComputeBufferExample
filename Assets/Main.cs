using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour {

    //Derived mainly from example online: https://forum.unity.com/threads/rwstructuredbuffer-in-vertex-shader.406592/
    
    // A simple object to render using our shader
    public GameObject cube;

    // A vector we'll use to pass to shader via the buffer,
    // and scale the dimensions of a cube in our example.
    // Change this in the editor at runtime to see the effect.
    public Vector3 scalingVector;

    //The object we use in C# to manage the compute buffer
    private ComputeBuffer computeBuffer;

    // The array used to fill the compute buffer
    private float[] data;

    // The number of elements in the buffer
    // Note that elements can be a struct, in which
    // case you declare the same type of struct in the shader.
    private int dataCount = 3;

    // stride - the size of each element in the buffer
    // looks to be in bytes, not surprisingly
    // must be multiple of 4 (max 2048, I belive)
    private int stride = sizeof(float);

    void Start () {
        //Create a new compute buffer object.
        //Use ComputeBuffer.Release to free it up when you're done
        computeBuffer = new ComputeBuffer(dataCount, stride, ComputeBufferType.Default /*type structured*/);

        //Alloc the data array
        data = new float[dataCount];

        //Assign the compute buffer to the shader.
        //Emperically, only have to do this once.
        //The name "buffer" passed here is the name of the variable in the shader
        cube.GetComponent<MeshRenderer>().material.SetBuffer("buffer", computeBuffer);

        //Update the data in buffer
        SetData();
	}
	
    private void SetData()
    {
        data[0] = scalingVector.x;
        data[1] = scalingVector.y;
        data[2] = scalingVector.z;

        //Pass the data to the compute buffer.
        //You can pass to only part of the buffer which is good for
        // efficiency in some use cases.
        computeBuffer.SetData(data);
 
    }

    // Update is called once per frame
    void Update () {

        //Update the data in buffer
        SetData();
	}
}
