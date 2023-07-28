#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
using namespace std;

float u0, v0;
float wpre_cen, HW0, h, HW, hw, f, hp, xw;
short *uv_array;
int   uv_size = 1000;
float x_array[960];
float x[1000][960];
float z[1000][960];
float z_array[960];
short datanum[1000][960];


struct CameraCaliParams
{
    float v_p1;
    float v_p2;
    float v_p3;
    float v_p4;
    float v_p5;
    float v_p6;
    float h_p1;
    float h_p2;
    float h_p3;
    float h_p4;
    float h_p5;
    float h_p6;
}   CamPara;

void readfile()
{
    //short data[1000][960];
    ifstream infile("z.txt");
    string num;
    int row = 0;
    while (getline(infile, num))
    {
        stringstream str(num);
        string num;
        int col = 0;
        while (getline(str, num, ','))
        {
            datanum[row][col] = static_cast<short>(stoi(num));
            col++;
        }
        row++;
    }
    infile.close();
}

void writefile()
{

    ofstream ofilex;
    ofilex.open("xr.txt");
    for (int i = 0; i < uv_size; i++)
    {
        for (int j = 0; j < 960; j++) 
        {
            ofilex << x[i][j] << ",";
        }
        ofilex << endl;
    }
    ofilex.close();

    ofstream ofilez;
    ofilez.open("zr.txt");
    for (int i = 0; i < uv_size; i++)
    {
        for (int j = 0; j < 960; j++)
        {
            ofilez << z[i][j] << ",";
        }
        ofilez << endl;
    }
    ofilez.close();
}

void UVtoXZ(short* uv_array, int uv_size, CameraCaliParams* cali_params, float* x_array, float* z_array)
{
    wpre_cen = static_cast<float>(CamPara.h_p3 * sin(CamPara.h_p5));
    HW0 = static_cast<float>(CamPara.h_p3 * cos(CamPara.h_p5));
    f = static_cast<float>(1 / (1 / CamPara.h_p3 + 1 / CamPara.h_p4));

    for (int i = 0; i < uv_size; i++)
    {
        v0 = static_cast<float>(uv_array[i]);
        //cout << v0 << endl;
        u0 = static_cast<float>(i);
        h  = static_cast<float>((v0 - CamPara.v_p1) * CamPara.h_p1 *CamPara.h_p3 * sin(CamPara.h_p6) / (CamPara.h_p4 * sin(CamPara.h_p5) - (v0 - CamPara.v_p1) * CamPara.h_p1 *sin(CamPara.h_p5 + CamPara.h_p6)));
        //cout << (v0 - CamPara.v_p1) * CamPara.h_p1 * CamPara.h_p3 * sin(CamPara.h_p6) << endl;
        HW = HW0 + h;
        hw = static_cast<float>(sqrt(HW * HW + wpre_cen * wpre_cen));
        hp = 1 / (1 / f - 1 / hw);
        xw = (hw * CamPara.h_p2 * (u0 - CamPara.v_p2)) / hp;
        x_array[i] = xw;
        z_array[i] = h;
    }
}

int main()
{
    CamPara.h_p1 = 0.0037;
    CamPara.h_p2=0.0038678055;
    CamPara.h_p3=354.8685913086;
    CamPara.h_p4=26.8893814087;
    CamPara.h_p5=0.2161882818;
    CamPara.h_p6=1.1529142857;
    CamPara.v_p1=638.4525;
    CamPara.v_p2=480.0670776367;
    CamPara.v_p3=24.9954090118;
    CamPara.v_p4=346.6080322266;
    CamPara.v_p5=76.1222229004;
    CamPara.v_p6=0.0000000000;

    readfile();

    for (int im = 0; im < uv_size; im++)
    {
        uv_array = datanum[im];
        UVtoXZ(uv_array, uv_size, &CamPara, x_array, z_array);

        for (int j = 0; j < 960; j++)
        {
            x[im][j] = x_array[j];
            z[im][j] = z_array[j];

        };
    }

    writefile();

    //writefile();

    cout << "Pixel to real, OK!\n";
}
