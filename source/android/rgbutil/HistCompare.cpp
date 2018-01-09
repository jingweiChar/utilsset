/*
 * Copyright (c) 2017 Guangdong OPPO Mobile Communication(Shanghai)
 * Corp.,Ltd. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of The Linux Foundation nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * First Created :        2018/03/26 Author: xuxin@Swdp.shanghai
 */

double compareHistYofYUV()
{
    int dims = 1;  // 创建一维直方图
    int sizes[] = {256};  // 共有256个取值范围
    int type = CV_HIST_ARRAY; // 表示使用密集多维矩阵结构
    int uniform = 1;
    float range[] = {0, 255}; // 取值范围为0-255
    float *ranges[] = {range};

    CvHistogram *hist1 = cvCreateHist(dims, sizes, type, ranges, uniform); // 创建直方图
    CvHistogram *hist2 = cvCreateHist(dims, sizes, type, ranges, uniform);

    IplImage *iplImage = cvCreateImageHeader(cvSize(w, h), IPL_DEPTH_8U,, 1);
    cvSetData(iplImage, data, w);

    cvCalcHist(&iplImage, hist1, 0, NULL); // 统计直方图
    cvNormalizeHist(hist1, 1.0); // 归一化

    cvCalcHist(&iplImage, hist2, 0, NULL);
    cvNormalizeHist(hist2, 1.0);

    double sim = cvCompareHist(hist1, hist2, CV_COMP_CORREL);

    cvReleaseHist(&hist1);
    cvReleaseHist(&hist2);

    return sim;
}
