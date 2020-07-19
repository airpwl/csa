%% ������cs�����㷨  ���� ѧ�ţ�19011110166
clear;
close all
%% ������Ҫ���� �ο��α�P157ҳP���κϳɿ׾��״�����
c=3e8;              %����3e8
lambda=0.4;     %����0.4m
f_c=c/lambda;        %Ƶ��=����/����
T_p=10e-6;           %������10us
PRF=1000;            %�����ظ�Ƶ��1000Hz
B=50e6;             %����50MHz
gamma=B/T_p;          %��Ƶ��
F_s=64e6;            %�����������64MHz
%R_s=15e3;             %ƽ̨�볡�����ĵľ���15km
R_s=4e3;             
V=120;              %�ɻ��ٶ�120m/s
D_a=1.2;             %���߷�λ��׾�����1.2m
W_r = 9e3;           %�������9km
theta=lambda/D_a;        %�������=����/���߷�λ��׾�����
T_a=theta*R_s/V;       %��λ��ϳɿ׾�ʱ��=�������*���ߵ��������ĵľ���
num_range=floor(8*T_p*F_s/2)*2;       %�������������
num_azimuth=floor(PRF*(T_a*1)/2)*2;      %��λ���������
t_hat=(-num_range/2:num_range/2-1)'/F_s+2*R_s/c; %�����������ʼ�����ʱ�䣬��ʱ��
t_m=(-num_azimuth/2:num_azimuth/2-1)/PRF;%��λ�������ʼ�����ʱ�䣬��ʱ��
%% ��Ŀ�������λ��
x_target_position=[0];    %��Ŀ��ĺ����꣬��λ��
y_target_position=[0]+R_s;%��Ŀ��������꣬������
figure;
% subplot(221);
plot(x_target_position,y_target_position,'rp');
axis([-30 30 3000 5000]);
title('Ŀ��λ��');
xlabel('��λ��');ylabel('������');
target_num=length(x_target_position);%Ŀ������
coordiante_azimuth=t_m*V;%��λ������=����������*�ɻ��ٶ�
signal_of_echo=zeros(num_range,num_azimuth);%���ڴ洢�ز��ź�
y_target=y_target_position;
%% �����ز��ź� Ŀ��ز��Ļ�Ƶ�ź��ھ����ʱ�䡪��λ��ʱ����Ĺ�ʽ �ο��α�P132ҳ��ʽ(5.9)
for k=1:num_azimuth
    %��Ŀ�����ڵ�λ����Ϊ������ԭ��
    x_target=x_target_position-coordiante_azimuth(k);
    for point_target_index=1:target_num
        %�ж�Ŀ���Ƿ��ڵ�ǰ�׾��ڣ��ӷ�λ������λ������a_a(t_m)
        if (atan(x_target(point_target_index)/y_target(point_target_index))<theta/2)&&(atan(x_target(point_target_index)/y_target(point_target_index))>-theta/2)
            %����ʱ���״�������λ������Ŀ���б��ΪR=R(t_m;;R_B)
            R=sqrt(x_target(point_target_index)^2+y_target(point_target_index)^2); 
            %�Ӿ��봰�����봰����a_r(t_hat-2*R/c)
            t0=2*R/c;
            a_r=((t_hat-t0)<T_p/2)&((t_hat-t0)>-T_p/2);
            %Ŀ��Ļز��Ļ�Ƶ�ź�
            %�α���Ӧ��ʽ��s(t_hat,t_m;R_B)=a_r*a_a*exp(j*pi*gamma*(t_hat-2*R/c)^2)*exp(-j*4*pi*R/lambda)
            target_echo=a_r.*exp(1i*pi*gamma*(t_hat-t0).^2)* exp(-1i*4*pi*R/lambda);
            %�ź����Ե���
            signal_of_echo(:,k)=signal_of_echo(:,k)+target_echo;
        end
    end
end

% ��ͼ
% ԭʼ�ز�����
figure;
subplot(2,2,1);
imagesc(real(signal_of_echo));
title('��a��ʵ��');
xlabel('����ʱ��');
ylabel('��λʱ��');

subplot(2,2,2);
imagesc(imag(signal_of_echo));
title('��b���鲿');
xlabel('����ʱ��');
ylabel('��λʱ��');

subplot(2,2,3);
imagesc(abs(signal_of_echo));
title('��c������');
xlabel('����ʱ��');
ylabel('��λʱ��');

subplot(2,2,4);
imagesc(angle(signal_of_echo));
title('��d����λ');
xlabel('����ʱ��');
ylabel('��λʱ��');

figure,
subplot(1,2,1);
imagesc(abs((fft2(signal_of_echo))));
title('��άƵ�׷���');
subplot(1,2,2);
imagesc(angle((fft2(signal_of_echo))));
title('��άƵ����λ');
%% Chirp Scaling �㷨  

%��Ŀ��ز��Ķ�����
f_a=-PRF/2:PRF/num_azimuth:(PRF/2-PRF/num_azimuth);      %��λ��Ƶ�ʣ�������Ƶ�ʣ�
%λ���ػ���ǰ����Ŀ��Ļز��Ķ����գ�����������
f_aM=2*V/lambda;
%б�ӽ�
sin_theta=f_a/f_aM;
cos_theta=sqrt(1-sin_theta.^2);
%�ز����ſ�ʱ�䷽�������Ե�Ƶ�ĵ�Ƶ��gamma_e���α�P140ҳ(5.38)
%�α���Ӧ��ʽ��gamma_e = 1/(1/gamma-R_B*2*lambda*sin_theta*sin_theta/(c^2*cos_theta*cos_theta*cos_theta))
gamma_e=1./(1/gamma-2*R_s*lambda*sin_theta.^2./(cos_theta.^3*c^2)); 
%cs���� a_f_a=1/sqrt(1-(f_a/f_aM)^2)-1=1/cos_theta-1
a_f_a=1./cos_theta-1;
%�α���Ӧ��ʽ��R(f_a;R_B)=R_B*a_f_a+R_B
R_fa_Rs=R_s+R_s*a_f_a;
%P155ҳ���ڸı��ߵ�Ƶ�ʳ߶ȵ�chirp scaling������λ����
%�α���Ӧ��ʽ��H_1=exp(j*pi*gamma_e*a_f_a*(t_hat-2*R/c)^2)
H_1=exp(1i*pi*(ones(num_range,1)*(gamma_e.*a_f_a)).*(t_hat*ones(1,num_azimuth)-2*ones(num_range,1)*R_fa_Rs/c).^2);
H_1=fftshift(H_1,2);
%% 1. ��λ��FFT�����źű任����ʱ��-��λƵ����
for i=1:num_range
    signal_of_echo(i,:)=fft(signal_of_echo(i,:));
end
figure;
imagesc(abs(signal_of_echo));
title('ԭʼ���ݱ任������������򣬷���');
figure;
subplot(1,2,1);
imagesc(abs((signal_of_echo)));
title('����������� ������');
subplot(1,2,2);
imagesc(angle((signal_of_echo)));
title('����������� ��λ��');
%% 2. ����ʱ��-��λ����������ź���chirp scaling������λ����H_1���
signal_of_echo=signal_of_echo.*H_1;
figure;
subplot(1,2,1);
imagesc(abs(signal_of_echo));
title('�����������chirp scaling�����󣬷�����');
subplot(1,2,2);
imagesc(angle(signal_of_echo));
title('�����������chirp scaling��������λ��');
%% 3. ������FFT����chirp scaling��������źű任������Ƶ��-��λƵ����
for i=1:num_azimuth
    signal_of_echo(:,i)=fft(signal_of_echo(:,i));
end
figure;
subplot(1,2,1);
imagesc(abs(signal_of_echo));
title('��chirp scaling��������źű任����άƵ�򣬷�����');
subplot(1,2,2);
imagesc(angle(signal_of_echo));
title('��chirp scaling��������źű任����άƵ����λ��');
%������Ƶ������
f_r=(-F_s/2:F_s/num_range:(F_s/2-F_s/num_range))';      
%���ھ���ѹ���������㶯У������λ����H_2
%�α���Ӧ��ʽ��H_2=exp(j*pi*f_r^2/(gamma_e(1+a_f_a)))exp(j*4*pi*R_s*a_f_a*f_r/c)
H_2=exp(1i*pi*f_r.^2./(gamma_e.*(1+a_f_a))).*exp(1i*4*pi*R_s*f_r*a_f_a/c);
H_2=fftshift(H_2);
%% 4. ������Ƶ��-��λƵ������ź�����λ����H_2��ˣ����źŽ��о���ѹ���;����㶯У��
signal_of_echo=signal_of_echo.*H_2;

s_rc=ifft2(signal_of_echo);
figure;
subplot(1,2,1);
imagesc(abs(s_rc));title('����ѹ���;����㶯У������źţ�������');xlabel('��λ��');ylabel('������');
subplot(1,2,2);
imagesc(angle(s_rc));title('����ѹ���;����㶯У������źţ���λ��');xlabel('��λ��');ylabel('������');
%% 5. �Խ��о������渵��Ҷ�任���任����ʱ��-��λƵ����
for i=1:num_azimuth
    signal_of_echo(:,i)=ifft(signal_of_echo(:,i));
end
figure;
subplot(1,2,1);
imagesc(abs(signal_of_echo));title('����ѹ���;����㶯У������źţ�������');xlabel('��λ��');ylabel('������');
subplot(1,2,2);
imagesc(angle(signal_of_echo));title('����ѹ���;����㶯У������źţ���λ��');xlabel('��λ��');ylabel('������');
%% 6. ���ڷ�λѹ������Ͳ�����chirp scaling�����ʣ����λ����H_3
%�α���Ӧ��ʽ��H_3=exp(j*2*pi*R_B*sqrt(f_aM^2-f_a^2)/V)exp(j*Theta_delta)
R__B=c/2/F_s*(-num_range/2:num_range/2-1)'+R_s;  %���������
%����chirp scaling���������ʣ����λTheta_delta(f_a;R_B)
Theta_delta=4*pi*(R__B-R_s).^2*(gamma_e.*a_f_a.*(1+a_f_a))/c^2;
H_3=exp(1j*2*pi/V*R__B*sqrt(f_aM.^2-f_a.^2)).*exp(1j*Theta_delta);
H_3=fftshift(H_3,2);
%% 7. ����ʱ��-��λƵ������ź���H_3��ˣ����з�λѹ������������chirp scaling�����ʣ����λ
signal_of_echo=signal_of_echo.*H_3;
figure;
subplot(1,2,1);
imagesc(abs(signal_of_echo));title('��λ��ѹ����λ�������ʱ��-��λƵ������źţ�������');xlabel('��λ��');ylabel('������');
subplot(1,2,2);
imagesc(angle(signal_of_echo));title('��λ��ѹ����λ�������ʱ��-��λƵ������źţ���λ��');xlabel('��λ��');ylabel('������');
%% 8. ���źŽ��з�λ���渵��Ҷ�任
for i=1:num_range
    signal_of_echo(i,:)=ifft(signal_of_echo(i,:));
end
figure;
subplot(1,2,1);
imagesc(abs(signal_of_echo));title('��λ��ѹ����λ���������յĳ�����');xlabel('��λ��');ylabel('������');
subplot(1,2,2);
imagesc(angle(signal_of_echo));title('��λ��ѹ����λ���������յĳ�����');xlabel('��λ��');ylabel('������');
%% �ֱ��ʷ���
Imaging_Result = signal_of_echo;
%��ֵ����
Interp_num = 8;
num_row = 32;
num_col = 100;
%Ŀ���λ�ã���������
target_position_row = num_range/2+1;
traget_position_col = num_azimuth/2+1;
data_0 = Two_Dim_Interpolate(Imaging_Result(target_position_row-num_row/2+1:target_position_row+num_row/2,traget_position_col-num_col/2+1:traget_position_col+num_col/2),Interp_num);
%���Ƴ������ĵȸ���
figure,contour(abs(data_0),30)
title('CS�㷨���յĳ�����');xlabel('��λ��');ylabel('������');
%% �Ծ����������Ƭ������sinc�������Σ�����sinc����3db����;�����ֱ��ʣ����зֱ��ʷ���
Interp_num = 8;
num_row = 64;
num_col = 200;
Img_Result_range_ori = Imaging_Result(target_position_row-num_row/2+1:target_position_row+num_row/2,traget_position_col);
%�����ֵ
Img_Res_range_irp = zeros(num_row*Interp_num,1);
Img_Res_range_irp(num_row*Interp_num/2-num_row/2+1:num_row*Interp_num/2+num_row/2,1) = fftshift(fft(fftshift(Img_Result_range_ori)));
Img_Res_range_irp = fftshift(ifft(fftshift(Img_Res_range_irp)));
figure,plot(20*log10(abs(Img_Res_range_irp)./max(abs(Img_Res_range_irp))))
title('CS�㷨����ľ�����sinc��������');xlabel('������');ylabel('���ȣ�dB��');
disp('PSLR��')
PSLR(Img_Res_range_irp)
disp('ISLR��')
ISLR(Img_Res_range_irp)
disp('������ֱ�������ֵ�� ��m��')
c/2/B
disp('������ֱ���ʵ��ֵ�� ��m��')
1.2*IRW(Img_Res_range_irp)/Interp_num*(c/2/F_s)     
%% �Է�λ�������Ƭ������sinc�������Σ�����sinc����3db����ͷ�λ��ֱ��ʣ����зֱ��ʷ���
Img_Result_azimuth_ori = Imaging_Result(target_position_row,traget_position_col-num_col/2+1:traget_position_col+num_col/2);
%�����ֵ
Img_Res_azimuth_irp = zeros(1,num_col*Interp_num);
Img_Res_azimuth_irp(1,num_col*Interp_num/2-num_col/2+1:num_col*Interp_num/2+num_col/2) = fftshift(fft(fftshift(Img_Result_azimuth_ori)));
Img_Res_azimuth_irp = fftshift(ifft(fftshift(Img_Res_azimuth_irp)));
figure,plot(20*log10(abs(Img_Res_azimuth_irp)./max(abs(Img_Res_azimuth_irp))))
title('CS�㷨����ķ�λ��sinc��������');xlabel('��λ��');ylabel('���ȣ�dB��');
disp('PSLR��')
PSLR(Img_Res_azimuth_irp)
disp('ISLR��')
ISLR(Img_Res_azimuth_irp)
disp('��λ��ֱ�������ֵ�� ��m��')
%lambda/(2*(V*num_azimuth/(PRF*R_s)))              % lambda/(2*theta_BW)
D_a/2
disp('��λ��ֱ���ʵ��ֵ�� ��m��')
1.2*IRW(Img_Res_azimuth_irp)/Interp_num*(V/PRF)