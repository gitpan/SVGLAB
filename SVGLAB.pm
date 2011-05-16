=c
Comment language:Chinese;
encoding:utf8;
contact: zhshchao@163.com/chenxupiaozhen@163.com
=cut
use utf8;
package SVGLAB;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(SVGLAB figure figend AXIS axis grid subplot rotate svg svgend gp gpend shq ShQ SHQ line rect circle ellipse polyline polygon path text vtext label xlabel ylabel title alink aend plot stem bar stest chg vector linspace vsin vcos poisson vpoisson load);
#@EXPORT_OK = qw($var1 $var2);
=instruction
中文名稱：意圖（模塊）鴻蒙版
英文名稱：perl SVGLAB module v1.0
作者：張士超
電郵：zhshchao@163.com
=cut

=c
版本號說明
中文版本號分兩位。
高位以千字文序：天地玄黄，……，焉哉乎也；
低位以天干序：甲乙丙丁戊己庚辛壬癸。
低位甲增至癸之際，高位易字，低位復甲。

與英文版本號之對應：
低位甲對1，字易數增；高位天對1，字易數增。
如：	天甲 == v1.1 ; 天乙 == v1.2 ; 天癸 == v2.0 ;
	地甲 == v2.1 ; 地丙 == v2.3 ; 宙辛 == v6.8 .
    
v1.0版實為首版，稱“鴻蒙”版。
天甲又可稱天字一版；
宙辛又可稱宙字八版。
=cut


#=========================#
#          版 本           #
#        鴻  *  蒙         #
#=========================#
   our $VERSION=1.0;
#=========================#

=c
集中開發日：2011年3月21日（週一）起兩週

=cut
my $Head='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
';
my $Tile='	<!-- 
	Generated using the Perl SVGLAB Module V1.0
	by Zhang Shichao
	email:zhshchao@163.com/zhangshichao@genomics.org.cn
 -->
</svg>';

my $zsI=1;	#文件名默認編號
my @zsvg;	#存儲正文所有元素,存儲數據，以備縮放.
my @ZSVG;	#正文串,由元素改寫的SVG串

my $IsOpen=0;#是否已打開寫一文件.使用於figure();figend();stest();
#==與文件屬性有關的變量==#
my $picInfo;#使用於：picInfo();picInfoWrite();
my $PREFIX='SVGLAB';
my $FigurePath;#自
my ($wide_all,$height_all)=(800,500);#圖片的高與寬,自
my ($xmin,$xmax,$ymin,$ymax);#轉換成的坐標.使用於axis();transform();自
#==#

#==與坐標轉換有關的7個變量==#
my $IsTrans_all=1;	#是否坐標變換.使用於aixs();transform();
my $IsScaleAxis_all=0;	#是否縮放坐標(即打破1個單位為一個像素).使用於aixs();transform();
my $IsKeep_all=0;		#是否保持縱橫比縮放坐標.使用於aixs();transform();
my $IsScaleRegion_all=0;	#是否縮放區域,空出上下左右邊.調用於axis();transform();
my $zoom=0.8;		#要縮放區域時,寬高均放縮為原長的$zoom倍,置於圖片正中.
my $IsCover_all=1;	#是否覆蓋空出的上下左右邊.調用於axis();transform();
my $IsAxisOn_all=0;#是否畫坐標軸
#==#

#==默認顏色==#顏色列表在程序最後#==#
my @COLORS;
cal_colours();
my $colI=1;		#默認顏色序號.從1始者,0為白色.
my $colNUM=$#COLORS+1;#顏色種數
#==#
#著"自"者,謂不必於initial()中初始.
#變量結'_all'者,謂全局.

sub SVGLAB{
	if($#_==-1){	#SVGLAB();
		$wide_all=800;
		$height_all=500;
		$PREFIX='SVGLAB';
	}elsif($#_==0){	#SVGLAB('prefix');
		$wide_all=800;
		$height_all=500;
		$PREFIX=shift;
		#$zsI=1;		#若新定義了$PREFIX,則$zsI置始.
	}elsif($#_==1){	#SVGLAB(800,500);
		$wide_all=shift;
		$height_all=shift;
		$PREFIX='SVGLAB';
	}elsif($#_==2){	#SVGLAB(800,500,'prefix');
		$PREFIX=shift;
		$wide_all=shift;
		$height_all=shift;		
		#$zsI=1;		#若新定義了$PREFIX,則$zsI置始.
	}
	$zsI=1;
}
sub initialize{
	$picInfo="";
	@zsvg=();
	@ZSVG=();
	$wide=$wide_all;$height=$height_all;
	
	$IsTrans=$IsTrans_all;#(1 && $IsTrans_all);
	$IsScaleAxis=$IsScaleAxis_all;#(0 or $IsScaleAxis_all);
	$IsKeep=$IsKeep_all;#(0 or $IsKeep_all);	
	$IsScaleRegion=$IsScaleRegion_all;#(0 or $IsScaleRegion_all);
	$IsCover=0;#$IsCover_all;#(1 && $IsCover_all);
	$IsAxisOn=$IsAxisOn_all;#(0 or $IsAxisOn_all);
	#IsTrans為一個figure-figend對内生效,IsTrans_all在所有它所掌管的figure-figend對内有效.其它同.
	
	$IsGrid=0;
	$IsSubPlot=0;#subplot()中定義
	$IsTitle=0;#title()中
}
sub figure{
	if($IsOpen){
		warn"[SVGLAB.pm]'figure()-figend()'mismatch,'figend()'missed:Figure \"$FigurePath\"hasn't been written.\n";
	}
	&initialize();#諸變量歸零,置空,賦初値等
	if($#_==-1){
		$FigurePath="$PREFIX$zsI.svg";
	}elsif($#_==0){	#衹給出文件名
		$FigurePath=$_[0];
	}elsif($#_==1){	#衹給出寬和高
		$FigurePath="$PREFIX$zsI.svg";
		$wide=$_[0];$height=$_[1];
	}elsif($#_==2){
		$FigurePath=$_[0];
		$wide=$_[1];$height=$_[2];
	}
	picInfo($wide,$height);
	#以下打開圖片文件：
	if(open ZS,">$FigurePath"){
		$IsOpen=1;
	}else{
		die"[SVGLAB.pm]Can't create \"$FigurePath.\n\"";
	}
	$xmin=0;$xmax=$wide;
	$ymin=0;$ymax=$height;#初始化坐標轉換參數
	$zsI+=1;
}

sub figend{
	if($IsOpen==0){
		warn"[SVGLAB.pm::figend]'figure()-figend()'mismatch:'figure()'missed.\n";
	}
	if($IsTrans){
		transform();#坐標轉換
	}
	if($IsAxisOn){
		axis_arrow();#畫於坐標轉換外
	}
	if($IsTitle){
		#$TITLE->[1][1]=calXaxis($TITLE->[1][1]);
		#$TITLE->[1][2]=calYaxis($TITLE->[1][2]);
		#push @zsvg,$TITLE;
	}
	if(defined@LABEL){
		foreach(@LABEL){
			push @zsvg,$_;
		}
	}
	print ZS$Head;	#1文件頭寫至文件
	picInfoWrite();	#將文件屬性寫至$INFO
	componentWrite();#諸圖片元素寫至$ZSVG
	print ZS$INFO;	#2文件屬性寫至文件
	foreach(@ZSVG){	#3諸圖片元素寫至文件
		print ZS;
	}
	@zsvg=();
	@ZSVG=();#俾勿影響下張圖
	@LABEL=();
	print ZS$Tile;	#4文件尾寫至文件,止
	close ZS;
	$IsOpen=0;
}
#====文件屬性=========#
sub picInfo{	#picture information
	$picInfo->[0][0]="width";
	$picInfo->[0][1]=$_[0];
	$picInfo->[1][0]="height";
	$picInfo->[1][1]=$_[1];
	#文件屬性例:
	#<svg height="800" width="1280" >
}
sub picInfoWrite{	#文件屬性寫入$INFO,再由figend()打印至文件
	$INFO="<svg ";
	foreach(@$picInfo){
		$INFO.="$_->[0]=\"$_->[1]\" ";
	}
	$INFO.='xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink">'."\n";#若不加入這兩個鏈接，則無法用火狐查看。但其它查看器沒問題。
	
}
#====文件屬性終=========#
#======坐標轉換======#
sub AXIS{
	if($IsOpen){
		die"[SVGLAB.pm::AXIS]'AXIS()' must out of 'figure-figend' pair.\n";
	}
	my $temp;
	if($#_==-1){	#AXIS;
		$IsTrans_all=1;		#是否坐標變換.使用於aixs();transform();
		#$IsScaleAxis_all=0;
		$IsKeep_all=0;	
		$IsScaleRegion_all=0;
		$IsCover_all=1;
	}elsif($#_==0){	#AXIS(0);AXIS(0.8);
		$temp=(shift or 0);
		if($temp==0){
			$IsTrans_all=0;
		}elsif($temp<1){
			$zoom=$temp;		#區域縮放系數
			$IsTrans_all=1;
			#$IsScaleAxis_all=0;	#是否縮放坐標.使用於aixs();transform();
			$IsKeep_all=0;		#是否保持縱橫比縮放坐標.使用於aixs();transform();
			$IsScaleRegion_all=1;	#縮放區域.調用於axis();transform();
			$IsCover_all=1;
		}elsif($temp==1){	#仍賦以默認値
			$IsTrans_all=1;		#是否坐標變換.使用於aixs();transform();
			#$IsScaleAxis_all=0;
			$IsKeep_all=0;	
			$IsScaleRegion_all=0;
			$IsCover_all=1;
		}
	}elsif($#_==3){	#AXIS(1,0,0,0,1);
		$temp=(shift or 0);		
		#$IsScaleAxis_all=(shift or 0);
		$IsKeep_all=(shift or 0);
		$IsScaleRegion_all=(shift or 0);
		$IsCover_all=(shift && 1);
		
		if($temp==0){
			$IsTrans_all=0;
		}elsif($temp==1){
			$IsTrans_all=1;
		}elsif($temp>0 && $temp<1){
			$zoom=$temp;
			$IsTrans_all=1;
			$IsScaleRegion_all=1;
		}else{
			die"[SVGLAB.pm::AXIS]Please specify number between 0 and 1 for the first parameter.\n";
		}
		
		if($IsTrans_all==0){
			if($IsKeep_all || $IsScaleRegion_all ==1){
				warn"[SVGLAB.pm::AXIS]If the first parameter of AXIS() is 0,then others must be 0 or omit them, just write AXIS(0).\n";
			}
		}
	}else{
		die"[SVGLAB.pm::AXIS]There must be none, 1 ,or 4 parameters for AXIS().\n";
	}
	
=c	調用方法:
	AXIS;		#默認情況，或回復默認
	AXIS(0);	#用SVG固有坐標系,不進行任何坐標轉換操作
	AXIS(0.8);	#置區域縮放系數為0.8
	AXIS(1,0,0,1)	#意為AXIS(是否轉換坐標系,縮放坐標時是否保持縱橫比,是否縮放區域,縮放區域後是否覆蓋邊界)
=cut
}
sub axis{	#axis()純供外調，内部不使用。為定坐標轉換諸屬性
	$IsScaleAxis=1 ;
	$IsScaleRegion=1;# or $IsScaleRegion_all);
	#$IsKeep=0;
	our (@allX,@allY);#記録所有圖片元素的坐標.使用於axis();traversal();
	my ($xmin_t,$ymin_t,$xmax_t,$ymax_t);
	if($#_==-1 or($#_==0&&$_[0] eq 1)){
		if($#_==0){$IsKeep=1;}
		if($#zsvg==-1){	#@zsvg為空
			$xmin=0;$xmax=$wide;
			$ymin=0;$ymax=$height;
		}else{
			traversal("a");#遍歷@zsvg中之坐標			
			if($#allX!=-1&&$#allY!=-1){
				($xmin_t,$xmax_t)=zsRange(@allX);
				($ymin_t,$ymax_t)=zsRange(@allY);#自動坐標之縮放
				($xmax,$xmin)=($xmax_t,$xmin_t)unless($xmax_t-$xmin_t==0);
				($ymax,$ymin)=($ymax_t,$ymin_t)unless($ymax_t-$ymin_t==0);
				
			}
			@allX=();@allY=();
		}
	}elsif($#_==0&&$_[0] eq"on"){
		$IsAxisOn=1;	#畫坐標軸
	}elsif($#_==3){
		($xmin,$xmax,$ymin,$ymax)=@_;#手動設置之坐標
		$IsCover=$IsCover_all;#$IsCover_all默認為1,可被AXIS設置.$IsCover默認為0,執行axis後默認為1,又可被AXIS設置為0
	}
=c	調用方法：
	axis;		#自適應坐標
	axis('on');	#顯示坐標軸
	axis(1);	#保持比例縮放
	axis(x1,x2,y1,y2);#設置坐標範圍
	
=cut
}
sub transform{
	our $side=(1-$zoom)/2;#為在axis_arrow()用,故our之
	our $xScale;#x坐標縮放比例,為在calXaxis(),calYaxis()中用
	our $yScale;#y坐標縮放比例,為在calXaxis(),calYaxis()中用
	our $xRange=($xmax-$xmin);
	our $yRange=($ymax-$ymin);
	my $keepScacle;#保持縱橫比坐標縮放系數
	our $xAdjust=0;#為在calXaxis(),calYaxis()中用
	our $yAdjust=0;#為在calXaxis(),calYaxis()中用
	
	if(!$IsScaleAxis){#若不縮放坐標
		$xScale=1;
		$yScale=1;
	}else{	#若縮放坐標
		if(!$IsKeep){#縮放坐標_不保持比例
			$xScale=$wide/$xRange;
			$yScale=$height/$yRange;
		}else{		#縮放坐標_保持比例
			$keepScacle=(zsRange($wide/$xRange,$height/$yRange))[0];#較小者為縮尺
			$xScale=$keepScacle;
			$yScale=$keepScacle;
		}
#here
	}
	if($IsScaleRegion){#若要縮放區域
		$xScale*=$zoom;
		$yScale*=$zoom;
		$xAdjust=$wide*$side;
		$yAdjust=$height*$side;#print"$xAdjust,$yAdjust\n";
	}	
	#print"$xmin,$xmax,$ymin,$ymax==$xScale,$yScale,$xAdjust,$yAdjust\n";
	
	if($IsSubPlot){
		traversal("s");#subplot畫子圖,在視系中先將諸坐標縮為四一,再移之至子位,送以下traversal("t")句以坐標轉換.
	}
	if($IsAxisOn){
		#axis_arrow();#畫於坐標轉換外
	}
	traversal("t");#坐標轉換在其中
	if($IsCover){
		my $pixel=10;
		rect(0,0,$wide,$side*$height-$pixel,0,0,'white',0,' ');#坐標不被轉換,即以SVG固有坐標系畫;上
		rect(0,0,$wide*$side-$pixel,$height,0,0,'white',0,' ');#左
		rect(0,(1-$side)*$height+$pixel,$wide,$side*$height,0,0,'white',0,' ');#下
		rect((1-$side)*$wide+$pixel,0,$wide*$side,$height,0,0,'white',0,' ');#右
	}
}
sub calXaxis{	#計算X坐標,供transform中之traversal()調;供axis_arrow()調
	my $xcoor=shift;
	$xcoor=$xcoor*$xScale-$xmin*$xScale+$xAdjust;
	$xcoor;
}
sub calYaxis{	#計算Y坐標,供transform中之traversal()調;供axis_arrow()調
	my $ycoor=shift;#print"-$ycoor*$yScale+$height+$ymin*$yScale+$yAdjust=";
	$ycoor=-$ycoor*$yScale+$height+$ymin*$yScale-$yAdjust;#print"$ycoor\n";
	$ycoor;
}
sub r_calXaxis{
	my $xcoor=shift;
	$xcoor=($xcoor-$xAdjust)/$xScale+$xmin;
	$xcoor;
}
sub r_calYaxis{	#計算Y坐標,供transform中之traversal()調;供axis_arrow()調
	my $ycoor=shift;
	$ycoor=$ymin-($ycoor+$yAdjust-$height)/$yScale;
	$ycoor;
}
sub subplot{
	if($#_!=2){
		warn"[SVGLAB.pm::subplot()]There must be 3 parameters:subplot(m,n,p).\n";
		return;#俾勿使$IsSubPlot為1.
	}
	our $IsSubPlot=1;
	my $m=shift;	#橫分m塊
	my $n=shift;	#縱分n塊
	my $p=shift;	#子於第p塊
	push @zsvg,["subplot",[$m,$n,$p]];
	#our $M=int($p/$m)+1;	#p子塊橫序號
	#our $N=$p-($M-1)*$m;	#p子塊縱序號
}
sub traversal{	#作用有三:一為納諸圖片對象坐標於考慮,以自適應圖片坐標(axis);二為將圖片變為子圖(subplot);
		#三為確定坐標參數後轉換這些對象的坐標(transform)
	my $Fun=shift;
	my($m,$n,$p,$M,$N)=(1,1,1,1,1);#仿subplot中,為竟subplot義
	foreach(@zsvg){
		if($_->[0]=~/^subplot$/){
			$m=$_->[1][0];
			$n=$_->[1][1];
			$p=$_->[1][2];
			$M=$p/$m;	#p子塊橫序號
			if($M-int($M)!=0){
				$M=int($M)+1;#向上取整
			}
			$N=$p-($M-1)*$m;	#p子塊縱序號
			next;
		}
		if($_->[0]=~/^rotate$/){
			if($Fun eq"t"){	#為transform()用				
				#$_->[1][0]=calXaxis($_->[1][0]);
				
				$_->[1][1]=calXaxis($_->[1][1]);
				
				$_->[1][2]=calYaxis($_->[1][2]);
			}
			#push @zsvg,["rotate",$_[0],$_[1],$_[2]];
		}elsif($_->[0]=~/^line$/){
			if($Fun eq"a"){	#為aixs()用,納諸圖片對象坐標於考慮
				push @allX,$_->[1][0];
				push @allX,$_->[1][2];
					
				push @allY,$_->[1][1];
				push @allY,$_->[1][3];
			}elsif($Fun eq"s"){#為subplot()用,將圖片變為子圖;不可與下面"t"部分利用代碼,故寫於此
				$_->[1][0]=$xmin+($_->[1][0]-$xmin)/$m+($N-1)/$m*$xRange;
				$_->[1][2]=$xmin+($_->[1][2]-$xmin)/$m+($N-1)/$m*$xRange;
				
				$_->[1][1]=$ymin+($_->[1][1]-$ymin)/$n+($n-$M)/$n*$yRange;
				$_->[1][3]=$ymin+($_->[1][3]-$ymin)/$n+($n-$M)/$n*$yRange;
			}elsif($Fun eq"t"){	#為transform()用,轉換這些對象的坐標
				$_->[1][0]=calXaxis($_->[1][0]);
				$_->[1][2]=calXaxis($_->[1][2]);
			
				$_->[1][1]=calYaxis($_->[1][1]);
				$_->[1][3]=calYaxis($_->[1][3]);
			}
		}elsif($_->[0]=~/^rect$/){
			if($Fun eq"a"){	#為aixs()用
				push @allX,$_->[1][0];
				push @allX,$_->[1][0]+$_->[1][2];
				
				push @allY,$_->[1][1];
				push @allY,$_->[1][1]-$_->[1][3];#矩形左下,右上兩點納入
			}elsif($Fun eq"s"){	#為subplot()用				
				$_->[1][0]=$xmin+($_->[1][0]-$xmin)/$m+($N-1)/$m*$xRange;
				$_->[1][2]=($_->[1][2])/$m;
				
				$_->[1][1]=$ymin+($_->[1][1]-$ymin)/$n+($n-$M)/$n*$yRange;
				$_->[1][3]=($_->[1][3])/$n;
				#print"$_->[1][3]\n";
			}elsif($Fun eq"t"){	#為transform()用				
				$_->[1][0]=calXaxis($_->[1][0]);
				$_->[1][2]=$_->[1][2]*$xScale;
				$_->[1][4]=$_->[1][4]*$xScale;
				#$_->[1][2]=calXaxis($_->[1][0]+$_->[1][2])-calXaxis($_->[1][0]);
				
				$_->[1][1]=calYaxis($_->[1][1]);
				$_->[1][3]=$_->[1][3]*$yScale;
				$_->[1][5]=$_->[1][5]*$yScale;
				#$_->[1][3]=calYaxis($_->[1][1])-calYaxis($_->[1][1]+$_->[1][3]);
				#print"$_->[1][3]\n";
			}
			#push @zsvg,["rect",[$x,$y,$rectWidth,$rectHeight,$fill,$stroke_width,$stroke,$rx,$ry]];
		}elsif($_->[0]=~/^circle$/){
			if($Fun eq"a"){	#為aixs()用
				push @allX,$_->[1][0]-$_->[1][2];
				push @allX,$_->[1][0]+$_->[1][2];
				
				push @allY,$_->[1][1]-$_->[1][2];
				push @allY,$_->[1][1]+$_->[1][2];#包含圓形的矩形之左下,右上兩點納入
			}elsif($Fun eq"s"){	#暫闕
			}elsif($Fun eq"t"){	#為transform()用				
				$_->[1][0]=calXaxis($_->[1][0]);
				
				$_->[1][1]=calYaxis($_->[1][1]);
				
				$_->[1][2]=$_->[1][2]*(vmin([$xScale,$yScale])->[0]);
				#其實縮放後就不是圓了，但circle衹能畫正圓。因此在坐標有縮放時，建議使用橢圓ellipse()
			}
			#push @zsvg,["circle",[$cx,$cy,$r,$PROPERTYS]];
		}elsif($_->[0]=~/^ellipse$/){
			if($Fun eq"a"){	#為aixs()用
				push @allX,$_->[1][0]-$_->[1][2];
				push @allX,$_->[1][0]+$_->[1][2];
				
				push @allY,$_->[1][1]-$_->[1][3];
				push @allY,$_->[1][1]+$_->[1][3];#包含橢圓的矩形之左下,右上兩點納入
			}elsif($Fun eq"s"){	#暫闕
			}elsif($Fun eq"t"){	#為transform()用				
				$_->[1][0]=calXaxis($_->[1][0]);
				
				$_->[1][1]=calYaxis($_->[1][1]);
				
				$_->[1][2]=$_->[1][2]*$xScale;
				$_->[1][3]=$_->[1][3]*$yScale;
			}
			#push @zsvg,["ellipse",[$cx,$cy,$rx,$ry,$PROPERTYS]];
		}elsif($_->[0]=~/^text$/){
			if($Fun eq"a"){	#為aixs()用
				push @allX,$_->[1][1];
				#push @allX,r_calXaxis(calXaxis($_->[1][1])+$_->[1][3]);
				
				push @allY,$_->[1][2];
				#push @allY,r_calYaxis(calYaxis($_->[1][2])+$_->[1][3]);#text所佔位置實兩矩形
			}elsif($Fun eq"s"){	#為subplot()用				
				$_->[1][1]=$xmin+($_->[1][1]-$xmin)/$m+($N-1)/$m*$xRange;				
				$_->[1][2]=$ymin+($_->[1][2]-$ymin)/$n+($n-$M)/$n*$yRange;
			}elsif($Fun eq"t"){	#為transform()用				
				$_->[1][1]=calXaxis($_->[1][1]);
				$_->[1][2]=calYaxis($_->[1][2]);
			}
			#push @zsvg,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
		}elsif($_->[0]=~/^p/){	#plot,polyline,polygon共用
			if($Fun eq"a"){	#為aixs()用
				foreach(@{$_->[1][0]}){
					push @allX,$_;
				}
				foreach(@{$_->[1][1]}){
					push @allY,$_;
				}
			}elsif($Fun eq"s"){	#為subplt()用
				foreach(@{$_->[1][0]}){
					$_=$xmin+($_-$xmin)/$m+($N-1)/$m*$xRange;
				}
				#print"$m,$n,$M,$N\n";
				foreach(@{$_->[1][1]}){
					$_=$ymin+($_-$ymin)/$n+($n-$M)/$n*$yRange;#print"$_\n";
				}
			}elsif($Fun eq"t"){	#為transform()用
				foreach(@{$_->[1][0]}){
					$_=calXaxis($_);
				}
				foreach(@{$_->[1][1]}){
					$_=calYaxis($_);
				}
			}
			#push @zsvg,["plot",[[@$xData],[@$yData],$stroke_width,$stroke,$stl]];
			#push @zsvg,["polyline",[[@$xData],[@$yData],$PROPERTYS]];
			#push @zsvg,["polygon",[[@$xData],[@$yData],$PROPERTYS]];
		}
	}
}
sub zsRange{	#數組中之最大最小値.主要供aixs()調用
	my $min=shift;
	my $max=$min;
	my @Data=@_;
	foreach(@Data){
		if($_>$max){
			$max=$_;
		}elsif($_<$min){
			$min=$_;
		}			
	}
	($min,$max);
}
sub axis_arrow{	#坐標軸，軸不受坐標轉換之影響，畫在其外
	my $arrow=0.012*$zoom*(zsRange($wide,$height))[0];#$arrow為寬高較小者之縮.為變量者,俾可調
	my $left=$side*$wide;
	my $right=(1-$side)*$wide;
	my $up=$side*$height;
	my $down=(1-$side)*$height;
	
	line($left-1,$down,$right+$arrow,$down);	#橫軸,左點至右點
	line($right,$down-$arrow,$right+$arrow,$down);
	line($right,$down+$arrow,$right+$arrow,$down);
	
	line($left,$down+1,$left,$up-$arrow);	#縰軸,下點至上點
	line($left-$arrow,$up,$left,$up-$arrow);
	line($left+$arrow,$up,$left,$up-$arrow);
	my  ($Range,$STEP,$i,$Begin,$tempStep);#變量解釋見下foreach中
	for("x","y"){	#畫標尺
		if($_ eq"x"){$Range=$xmax-$xmin;}else{$Range=$ymax-$ymin;}
		
		$STEP=cal_step($Range);#計算最佳步長
		
		if($_ eq"x"){	#x軸上標尺
			$Begin=(int($xmin/$STEP))*$STEP;#起點為步長整倍數的最小數(未必是整數).
			$tempStep=$Begin;
			while($tempStep<=$xmax){
				if($tempStep<$xmin){$tempStep+=$STEP;next;}#防止畫出已縮視圖之外
				if(abs($tempStep)<1e-10){$tempStep=0;}#防止奇異標籤
				line(calXaxis($tempStep),$down+0.3*$arrow,calXaxis($tempStep),$down-0.3*$arrow);
				text($tempStep,calXaxis($tempStep)-4*length($tempStep),$down+20);
				if($tempStep==$xmin){	#不將網格虚線畫於軸
					$tempStep+=$STEP;
					next;
				}
				if($IsGrid){	#網格
					if($GridsPatten=~/x/i or $GridsPatten eq ""){	#y嚮網格
						shq("stroke-dasharray=\"$arrow\"");
						line(calXaxis($tempStep),$up,calXaxis($tempStep),$down);
					}
				}
				$tempStep+=$STEP;
			}
		}else{	#y軸上標尺
			$Begin=(int($ymin/$STEP))*$STEP;#起點為步長整倍數的最小數(未必是整數).
			$tempStep=$Begin;
			while($tempStep<=$ymax){
				if($tempStep<$ymin){$tempStep+=$STEP;next;}#防止畫出已縮視圖之外
				if(abs($tempStep)<1e-10){$tempStep=0;}#防止奇異標籤
				line($left+0.3*$arrow,calYaxis($tempStep),$left-0.3*$arrow,calYaxis($tempStep));
				text($tempStep,$left-10*length($tempStep),calYaxis($tempStep)+5);
				if($tempStep==$ymin){	#不將網格虚線畫於軸
					$tempStep+=$STEP;
					next;
				}
				if($IsGrid){	#網格
					if($GridsPatten=~/y/i or $GridsPatten eq ""){	#x嚮網格
						shq("stroke-dasharray=\"$arrow\"");
						line($left,calYaxis($tempStep),$right,calYaxis($tempStep));
					}
				}
				$tempStep+=$STEP;
			}
		}
	}
	text("X",$right+0.2*$side*$wide,$down+20);
	text("Y",$left-30,$up-0.2*$side*$height);
}
sub cal_step{	#主為axis_arrow調.
	my $Range=shift;
	$STEP=$Range/10;#標尺步長
	$STEP=~s/[1-9]/a/;	#首個非零數字以"a"替
	$STEP=~s/[^a\.]/0/g;	#除"a"和小數點外所有數字變為0
	$STEP=~s/a/1/;		#"替"a"為1,如是得到如 ... , 0.01 , 0.1 , 1 , 10 , 100 , ...這樣的步長
				#如 ... , 0.05 , 0.5 , 5 , 50 , 100 , ...的步長
	#print"$Range,$STEP\n";
	$i=(vmin([abs($Range/$STEP-10),abs($Range/$STEP/5-10),abs($Range/$STEP/10-10)]))->[1];
									#三種步長孰最接近10步步盡$Range
	#print"$i,abs($Range/10-$STEP),abs($Range/10-$STEP*5)\n";
	if($i==1){
		$STEP*=5;
	}elsif($i==2){
		$STEP*=10;
	}#最佳步長
	$STEP;
}
sub grid{
	our $IsGrid=1;
	our $GridsPatten=($_[0] or '');#"x","y",或""則兩軸均畫.若是數字，則不在意
	my $i;
	my $dash=0.1*0.1*(zsRange($wide,$height))[0];#仿axis_arrow()中者
	if($#_==0){
		if($GridsPatten=~/[xy]/i or $GridsPatten eq ""){
			return;
		}else{	#數字,作網格之數
			my $Num=$_[0];
			for$i(1..$_[0]){	#從1始者,不將虚線畫於軸
				shq("stroke-dasharray=\"$dash\"");
				line($i/$Num*($xmax-$xmin)+$xmin,$ymax,$i/$Num*($xmax-$xmin)+$xmin,$ymin);#y嚮網格
				
				shq("stroke-dasharray=\"$dash\"");
				line($xmin,$i/$Num*($ymax-$ymin)+$ymin,$xmax,$i/$Num*($ymax-$ymin)+$ymin);#x嚮網格
			}
		}
	}elsif($#_==1){
		my $Num=$_[0];
		for$i(1..$_[0]){
			shq("stroke-dasharray=\"$dash\"");
			line($i/$Num*($xmax-$xmin)+$xmin,$ymax,$i/$Num*($xmax-$xmin)+$xmin,$ymin);#y嚮網格
		}
		$Num=$_[1];
		for$i(1..$_[1]){
			shq("stroke-dasharray=\"$dash\"");
			line($xmin,$i/$Num*($ymax-$ymin)+$ymin,$xmax,$i/$Num*($ymax-$ymin)+$ymin);#x嚮網格
		}
	}
}
sub cover{
	
}
#======坐標轉換終=====#

#====初始化與檢驗=====#

sub stest{
	if($IsOpen){
		die"[SVGLAB.pm]'figend()'missed.\n";
	}
}
#====初始化與檢驗終=====#


##==================以下子過程用生成文件之正文==================##


#====元素子過程=========#
sub svg{
	my $zsvg;
	if($#_==-1){
		$zsvg="<svg>";
	}elsif($#_==0){
		$zsvg="<svg x=\"$_[0]\">";
	}elsif($#_==1){
		$zsvg="<svg x=\"$_[0]\" y=\"$_[1]\">";
	}else{
		warn"[SVGLAB.pm::svg()]Your input is too much.\n";
	}
	push @zsvg,[$zsvg];
	#svg例：
	#<svg x="10">
}
sub svgend{
	push @zsvg,["</svg>"];
	#svg END例：
	#</svg>
}


sub gp{
	my $zsgp;
	if($#_==-1){
		$zsgp="<g";
	}elsif($#_==2){
		$zsgp="<g transform=\"rotate($_[0] $_[1] $_[2])\"";#不結以'>'者，為插$shq之用
	}else{
		warn"[SVGLAB.pm::group()]Must exactly 3 parameters or None.\n";
	}
	push @zsvg,[$zsgp];
	#svg例：
	#<svg x="10">
}
sub gpend{
	push @zsvg,["</g>"];
	#group END例：
	#</g>
}
sub shq{
	push @zsvg,["shq",shift];
}
sub ShQ{
	my $prop=shift;
	my @prop=split /[\s;]+/,$prop;
	my %Phash=('xx'=>'stroke-dasharray','tm'=>'fill-opacity','xtm'=>'opacity');
	#xx，虚線；tm，透明；xtm，線透明
	my @zs;
	foreach(@prop){
		@zs=split /:/,$_;
		if(exists $Phash{$zs[0]}){
			shq("$Phash{$zs[0]}=\"$zs[1]\"");
		}
	}
}
sub SHQ{
	my $prop=shift;
	my @prop=split /[\s;]+/,$prop;
	my %Phash=('sd'=>'stroke-dasharray','fo'=>'fill-opacity','o'=>'opacity');
	#xx，虚線；tm，透明；xtm，線透明
	my @zs;
	foreach(@prop){
		@zs=split /:/,$_;
		if(exists $Phash{$zs[0]}){
			shq("$Phash{$zs[0]}=\"$zs[1]\"");
		}
	}
}
sub rotate{
	push @zsvg,["rotate",[$_[0],$_[1],$_[2]]];
}
sub line{
	my $x1=shift;
	my $y1=shift;
	my $x2=shift;
	my $y2=shift;
	my $stroke_width=(shift or 1);
	my $stroke=(shift or "black");
	push @zsvg,["line",[$x1,$y1,$x2,$y2,$stroke_width,$stroke]];
	#line例:
	#<line id="LB_H1" stroke="blue" stroke-width="1" x1="275.82" x2="276.01" y1="400" y2="590" />
}

sub rect{
	my $x=shift;
	my $y=shift;
	my $rectWidth=shift;
	my $rectHeight=shift;
	my $rx=(shift or 0);
	my $ry=(shift or 0);
	
	my $fill=(shift or "blue");#填充顏色
	my $stroke_width=shift;#(shift or 0);#框像素寬
	my $stroke=shift;#(shift or "");#框色

	my $LINE_PROPERTY='';
	$LINE_PROPERTY.=" fill=\"$fill\" ";
	if(defined $stroke_width){
		$LINE_PROPERTY.=" stroke-width=\"$stroke_width\" ";
	}
	if(defined $stroke){
		$LINE_PROPERTY.=" stroke=\"$stroke\" ";
	}
	
	push @zsvg,["rect",[$x,$y,$rectWidth,$rectHeight,$rx,$ry,$LINE_PROPERTY]];#$fill,$stroke_width,$stroke]];
}
sub circle{
	my $cx=shift;
	my $cy=shift;
	my $r=shift;
	
	my $fill=(shift or "blue");#填充顏色
	my $stroke_width=shift;#(shift or 0);#框像素寬
	my $stroke=shift;#(shift or "");#框色
	
	my $PROPERTYS='';
	$PROPERTYS.=" fill=\"$fill\" ";
	if(defined $stroke_width){
		$PROPERTYS.=" stroke-width=\"$stroke_width\" ";
	}
	if(defined $stroke){
		$PROPERTYS.=" stroke=\"$stroke\" ";
	}
	push @zsvg,["circle",[$cx,$cy,$r,$PROPERTYS]];
}
sub ellipse{
	my $cx=shift;
	my $cy=shift;
	my $rx=shift;
	my $ry=shift;
	
	my $fill=(shift or "blue");#填充顏色
	my $stroke_width=shift;#(shift or 0);#框像素寬
	my $stroke=shift;#(shift or "");#框色
	
	my $PROPERTYS='';
	$PROPERTYS.=" fill=\"$fill\" ";
	if(defined $stroke_width){
		$PROPERTYS.=" stroke-width=\"$stroke_width\" ";
	}
	if(defined $stroke){
		$PROPERTYS.=" stroke=\"$stroke\" ";
	}
	push @zsvg,["ellipse",[$cx,$cy,$rx,$ry,$PROPERTYS]];
}
sub polyline{
	my $xData=shift;
	my $yData=shift;
	if($#{$xData}!=$#{$yData}){
		die"[SVGLAB.pm::polyline()]x&y's dimension doesn't match.\n";
	}
	my $fill=(shift or "white");#填充顏色
	my $stroke_width=(shift or 1) ;#stroke-width
	my $stroke=(shift or "black");#stroke
	
	my $PROPERTYS='';
	$PROPERTYS.=" fill=\"$fill\" ";
	if(defined $stroke_width){
		$PROPERTYS.=" stroke-width=\"$stroke_width\" ";
	}
	if(defined $stroke){
		$PROPERTYS.=" stroke=\"$stroke\" ";
	}
	push @zsvg,["polyline",[[@$xData],[@$yData],$PROPERTYS]];
}
sub polygon{
	my $xData=shift;
	my $yData=shift;
	if($#{$xData}!=$#{$yData}){
		die"[SVGLAB.pm::polygon()]x&y's dimension doesn't match.\n";
	}
	my $fill=(shift or "white");#填充顏色
	my $stroke_width=(shift or 1);#stroke-width
	my $stroke=(shift or "black");#stroke
	
	my $PROPERTYS='';
	$PROPERTYS.=" fill=\"$fill\" ";
	if(defined $stroke_width){
		$PROPERTYS.=" stroke-width=\"$stroke_width\" ";
	}
	if(defined $stroke){
		$PROPERTYS.=" stroke=\"$stroke\" ";
	}
	push @zsvg,["polygon",[[@$xData],[@$yData],$PROPERTYS]];
}
sub path{
}
sub text{
	my $text=shift;
	my $x=shift;
	my $y=shift;
	my $size=(shift or 14);
	my $font=(shift or "Arial") ;
	my $fill=(shift or "");
	my $stroke=(shift or "");
	push @zsvg,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
=c	text例：
	<text x="20"  y="40"
          style="font-family: Arial;
                 font-size  : 34;
                 stroke     : #000000;
                 fill       : #00ff00;
                "
          >Styled SVG text</text>
=cut
}
sub vtext{
	my $text=shift;
	my $x=shift;
	my $y=shift;
	my $size=(shift or 14);
	my $font=(shift or "Arial") ;
	my $fill=(shift or "");
	my $stroke=(shift or "");
	my $downMove=0;
	foreach(split //,$text){
		push @zsvg,["text",[$_,$x,$y+$downMove,$size,$font,$fill,$stroke]];
		$downMove+=$size;
	}
}
sub label{
	my $text=shift;	
	my $size=(shift or 20);
	my $font=(shift or "Arial") ;
	my $x=(shift or 0);
	my $y=(shift or 0);
	my $fill=(shift or "");
	my $stroke=(shift or "");
	our @LABEL;
	push @LABEL,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
}
sub xlabel{
	my $text=shift;	
	my $size=(shift or 15);
	my $font=(shift or "Arial") ;
	my $x=(shift or  $wide/2-length($text)*$size/3);
	my $y=(shift or $height*(1-(1-$zoom)/4)+$size/2);
	my $fill=(shift or "");
	my $stroke=(shift or "");
	push @LABEL,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
}
sub ylabel{
	my $text=shift;	
	my $size=(shift or 15);
	my $font=(shift or "Arial") ;
	my $x=(shift or  $wide*(1-$zoom)/4);
	my $y=(shift or $height/2+length($text)*$size/3);
	my $fill=(shift or "");
	my $stroke=(shift or "");
	push @LABEL,['shq',"transform=\"rotate(-90 $x $y)\""];
	push @LABEL,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
}
sub title{	#寫在坐標轉換外,故用SVG固有坐標系
	my $text=shift;	
	my $size=(shift or 20);
	my $font=(shift or "Arial") ;
	my $x=(shift or $wide/2-length($text)*$size/3);
	my $y=(shift or $height*(1-$zoom)/4);
	my $fill=(shift or "");
	my $stroke=(shift or "");
	our $IsTitle=1;	
	push @LABEL,["text",[$text,$x,$y,$size,$font,$fill,$stroke]];
}
sub alink{	#SVG中的'a'元素.
	my $Location=shift;
	my $type=shift;
	my $aLink="<a ";
	if(defined $Location){#地址
		if($Location=~/^www\./){
			$Location="http://".$Location;
		}
		$aLink.=" xlink:href=\"$Location\" ";
	}
	if(defined $type){#打開方式
		$aLink.=" xlink:show=\"$type\" ";
	}
	push @zsvg,[$aLink]
}
sub aend{
	push @zsvg,["</a>"];
	#鏈接a例：
	#</a>
}

sub plot{	#自定義的類型,SVG中無
	my $xData=shift;
	my $yData=shift;
	if($#{$xData}!=$#{$yData}){
		die"[SVGLAB.pm::plot()]x&y's dimension doesn't match.\n";
	}
	my $stroke_width=(shift or 1);#stroke-width
	my $stroke=(shift or"blue");#stroke
	my $stl=shift;#style,如"*",則以*描圖，如matlab然
	my $i;
	
	if(defined $stl){
		shq("stroke=\"$stroke\"");#作用於gp(),實現曲線的諸直線以共同參數.
		gp;
		for$i(0..$#{$xData}){
			text($stl,$xData->[$i],$yData->[$i],10);	#打印為text元素
		}
		gpend;
	}else{
		shq("stroke-width=\"$stroke_width\" stroke=\"$stroke\"");#作用於gp(),實現曲線的諸直線以共同參數.
		gp;
		push @zsvg,["plot",[[@$xData],[@$yData]]];#不要將引用儲存，再一次血的教訓，如$xData要寫為[@$xData]，將引用變為數據！
		gpend;		
	}
}
sub PLOT{	#將外部（調用ZSVG模塊的程序）傳入plot的參數轉化為SVG元素,由componentWrite()調用，不供外調
	my $zs=$_[0];#傳入的數據形式為：[$xData,$yData,$w,$stk,$stl]]，plot中生成者
	my $i;
	if(defined $zs->[4]){
		
	}else{
		for$i(1..$#{$zs->[0]}){	# $xData的每一維
			$COMP="<line x1=\"$zs->[0][$i-1]\" y1=\"$zs->[1][$i-1]\" x2=\"$zs->[0][$i]\" y2=\"$zs->[1][$i]\" />\n";
			#$COMP="<line x1=\"$zs->[0][$i-1]\" y1=\"$zs->[1][$i-1]\" x2=\"$zs->[0][$i]\" y2=\"$zs->[1][$i]\" stroke-width=\"$zs->[2]\" stroke=\"$zs->[3]\"/>\n";
			push@ZSVG,$TAB.$COMP;
		}
	}
}
#==以下,幾個上層調用==#
#所謂上層調用,為言若定義於模塊外,不影響其使用.與模塊内部變量無特別依賴關係.
sub stem{
	my $xData=shift;
	my $yData=shift;
	if($#{$xData}!=$#{$yData}){
		die"[SVGLAB.pm::stem()]x&y's dimension doesn't match.\n";
	}
	my $stroke_width=(shift or 1);#stroke-width
	my $stroke=(shift or"blue");#stroke
	
	my ($stemXmin,$stemXmax)=zsRange(@$xData);
	my ($stemYmin,$stemYmax)=zsRange(@$yData);
	my $stemR=(zsRange($stemXmax-$stemXmin,$stemYmax-$stemYmin))[1]/200;
	my $stemRx=($stemXmax-$stemXmin)/$wide*3;
	my $stemRy=($stemYmax-$stemYmin)/$height*3;
	my $i;
	gp;
	line($stemXmin,0,$stemXmax,0);
	for$i(0..$#{$xData}){
		#circle($xData->[$i],$yData->[$i],$stemR,'white',$stroke_width,$stroke);
		ellipse($xData->[$i],$yData->[$i],$stemRx,$stemRy,'white',$stroke_width,$stroke);
		line($xData->[$i],0,$xData->[$i],$yData->[$i],$stroke_width);
		
	}
	gpend;
	#axis($stemXmin,$stemXmax,$stemYmin,$stemYmax);
	#push @zsvg,["stem",[[@$xData],[@$yData]]];#
}
sub bar{
	my $Data=shift;
	my $barNames=shift;
	my $apart=shift;#間隔與条寬的比例,下將設默認為0.3.
	my $barColours=shift;
	
	my @barNames=defined $barNames ? split /[\s\,]+/,$barNames : undef;
	$apart=defined $apart ? $apart : 0.3;
	my @barColours=defined$barColours ? split /[\s\,]+/,$barColours : @COLOURS;
	
	
	my $barZoom=0.7;
	my $barYmax=(zsRange(@$Data))[1];
	my $barYscale=$height*$barZoom/$barYmax;
	
	my $barWidth=$wide*$barZoom/($#{$Data}+1+$#{$Data}*$apart);#条寬
	my $xStep=$barWidth*(1+$apart);			#步長像素數
	
	my($xs,$ys)=((1-$barZoom)/2*$wide,$height*(1-$barZoom)/2);#x start,y start
	my($xe,$ye)=($xs+$wide*$barZoom,$ys+$height*$barZoom);	#x end,y end
	for$i(0..$#{$Data}){
		rect($xs+$i*$xStep,$ys,$barWidth,$Data->[$i]*$barYscale,0,0,$barColours[$i+1]);
		if(defined$barNames[$i]){
			text($barNames[$i],$xs+$i*$xStep+$barWidth/2-length($barNames[$i])*20/3,$ys-20,20);
		}
	}
	line($xs,$ys,$xe,$ys);#x軸
	line($xs,$ys,$xs,$ye);#y軸
	my $yStep=cal_step($barYmax);
	my $yLoc=0;#y location
	while($yLoc<=$barYmax){	#y軸標籤
		text($yLoc,$xs-length($yLoc)*15,$yLoc*$barYscale+$ys-5);#y標籤
		line($xs-3,$yLoc*$barYscale+$ys,$xs+3,$yLoc*$barYscale+$ys);#標尺
		$yLoc+=$yStep;
	}
	
	#bar($data,'name1,name2,..,nameN',0.3,'blue,red,yellow,green,...');
}

#==以上,幾個上層調用==#
sub componentWrite{	#諸元素寫入@ZSVG,再由figend()打印至文件
	my $COMP="";
	our $TAB="";#亦供PLOT()之調
	my ($text_x,$text_y);
	my $shq='';
	my $shq_animate='';
	my $points='';#為polyline和polygon用
	my $i;
	foreach$comp(@zsvg){
		if($comp->[0]=~/^shq$/){
			if($comp->[1]=~/^\s*<animate/){	#動畫效果,寫入元素中
				$shq_animate="\n\t$comp->[1]\n";
			}elsif($comp->[1]=~/^\s*</){	#元素,寫在其它元素外
				push @ZSVG,$TAB."$comp->[1]\n";
			}else{	#元素屬性寫入元素中
				$shq.=" ".$comp->[1]." ";
			}
		}elsif($comp->[0]=~/^rotate$/){		#rotate
			$shq.=" transform=\"rotate($comp->[1][0] $comp->[1][1] $comp->[1][2])\" ";
		}elsif($comp->[0]=~/^<[^\/]/){		#svg,group,a
			push@ZSVG,$TAB.$comp->[0].$shq.">".$shq_animate."\n";
			$TAB.="\t";
			$shq='';
			$shq_animate='';
		}elsif($comp->[0]=~/^<\//){	#svg,group,a等之END
			$TAB=~s/\t//;
			push@ZSVG,$TAB.$comp->[0]."\n";
		}elsif($comp->[0]=~/^plot$/){	#plot不支持shq,因其畫線很多，故畫在一羣組group内,賦相同屬性
			if(!defined $comp->[1][4]){	#若$stl有定義,則plot()已將其轉換為text()對象,在text()中畫出
				PLOT($comp->[1]);
				#$COMP="";
			}
		}elsif($comp->[0]=~/^line$/){	#line 
			$COMP="<line x1=\"$comp->[1][0]\" y1=\"$comp->[1][1]\" x2=\"$comp->[1][2]\" y2=\"$comp->[1][3]\" stroke-width=\"$comp->[1][4]\" stroke=\"$comp->[1][5]\" $shq>$shq_animate</line>\n";	
			push @ZSVG,$TAB.$COMP;
			#print"$shq\n";
			$shq="";
			$shq_animate='';
			#$COMP="";
		}elsif($comp->[0]=~/^rect$/){
			$COMP="<rect x=\"$comp->[1][0]\" y=\"$comp->[1][1]\" width=\"$comp->[1][2]\" height=\"$comp->[1][3]\" rx=\"$comp->[1][4]\" ry=\"$comp->[1][5]\"  $comp->[1][6] $shq>$shq_animate</rect>\n";
			push @ZSVG,$TAB.$COMP;
			$shq="";
			$shq_animate='';
			#push @zsvg,["rect",[$x,$y,$rectWidth,$rectHeight,$rx,$ry,$LINE_PROPERTY]];
		}elsif($comp->[0]=~/^circle$/){
			$COMP="<circle cx=\"$comp->[1][0]\" cy=\"$comp->[1][1]\" r=\"$comp->[1][2]\" $comp->[1][3] $shq>$shq_animate</circle>\n";
			push @ZSVG,$TAB.$COMP;
			$shq="";
			$shq_animate='';
			#push @zsvg,["circle",[$cx,$cy,$r,$PROPERTYS]];
		}elsif($comp->[0]=~/^ellipse$/){
			$COMP="<ellipse cx=\"$comp->[1][0]\" cy=\"$comp->[1][1]\" rx=\"$comp->[1][2]\" ry=\"$comp->[1][3]\" $comp->[1][4] $shq>$shq_animate</ellipse>\n";
			push @ZSVG,$TAB.$COMP;
			$shq="";
			$shq_animate='';
			#push @zsvg,["circle",[$cx,$cy,$r,$PROPERTYS]];
		}elsif($comp->[0]=~/^poly/){	#polyline和polygon共
			$points="points=\"";
			for$i(0..$#{$comp->[1][0]}){
				$points.="$comp->[1][0][$i],$comp->[1][1][$i]  ";
				#print"$i,$comp->[1][0][$i],$comp->[1][1][$i]\n";
			}
			$points.='"';
			$COMP="<$comp->[0] $points $comp->[1][2] $shq>$shq_animate</$comp->[0]>\n";
			push @ZSVG,$TAB.$COMP;
			$shq="";
			$shq_animate='';
			#push @zsvg,["polyline",[[@$xData],[@$yData],$PROPERTYS]];
			#push @zsvg,["polygon",[[@$xData],[@$yData],$PROPERTYS]];
		}elsif($comp->[0]=~/^text$/){	#test
			$text_x=$comp->[1][1];#-length($comp->[1][0])/2*$comp->[1][3]/1.732;
			$text_y=$comp->[1][2];#+$comp->[1][3]/3.46;
			$COMP.=$TAB."<text x=\"$text_x\" y=\"$text_y\"$shq\n";
			$COMP.=$TAB."\t"."style=\"font-family: $comp->[1][4];\n";
			$COMP.=$TAB."\t"."font-size : $comp->[1][3];\n";
			$COMP.=$TAB."\t"."stroke : $comp->[1][6];\n";
			$COMP.=$TAB."\t"."fill : $comp->[1][5];\"\n";
			$COMP.=$TAB."\t".">$comp->[1][0]$shq_animate</text>\n";
			push @ZSVG,$COMP;
			$shq='';
			$shq_animate='';
			#$COMP="";
		}
		$COMP="";
	}
}
#====元素子過程終=========#
##==================生成文件正文之子過程終==================##


#以下補充若干數學函數，以資調用.除vmin()外,本模塊未調用.
sub vector{
	my $bg=$_[0];
	my $len=int(($_[2]-$bg)/$_[1]);
	my $x=[$bg];
	for my$i(1..$len){
		$x->[$i]=$x->[$i-1]+$_[1];
	}
	$x;
	#此程序產生向量引用，如此調用：$v=vec(起,距,止);如:$v=vec(1 , 0.1 , 3);
}
sub linspace{
	my $bg=$_[0];
	my $len=$_[2];#向量長
	my $step=($_[1]-$_[0])/$len;
	my $x=[$bg];
	for my$i(1..$len){
		$x->[$i]=$x->[$i-1]+$step;
	}
	$x;
}
sub chg{	#cheng此乘除算法只能處理引用，若向量只有單元素,如$x=3,須這樣录入：$x=[3];chg($x,num);
	my($x,$chsh,$i);
	$x=shift;
	$chsh=shift;#chengShu;
	for$i(0..$#$x){
		$x->[$i]=($x->[$i])*$chsh;
	}
	$x;
}
sub vsin{
	my $x=shift;my $i;my $y;
	for $i(0..$#{$x}){
		$y->[$i]=sin($x->[$i]);
	}
	$y;
}
sub vcos{
	my $x=shift;my $i;my $y;
	for $i(0..$#{$x}){
		$y->[$i]=cos($x->[$i]);
	}
	$y;
}
sub poisson{
	my $lamda=shift;
	my $k=shift;
	my $poisson=exp(-$lamda)*($lamda**$k);
	my $i;
	for$i(1..$k){
		$poisson/=$i;
	}
	if($poisson=='inf'){
		die"[SVGLAB.pm::piosson()]Number out of range.\n";
	}
	$poisson;
}
sub vpoisson{
	my $lamda=shift;
	my $k=shift;
	my $i;my $y;
	for $i(0..$#{$k}){
		$y->[$i]=poisson($lamda,$k->[$i]);
	}
	$y;
}
sub vmin{	#衹在axis_arrow()中調用
	my $vector=shift;
	my $vmin->[0]=$vector->[0];
	$vmin->[1]=0;
	my $i;
	for$i(1..$#{$vector}){
		if($vector->[$i] < $vmin->[0]){
			$vmin->[0]=$vector->[$i];
			$vmin->[1]=$i;
		}
	}
	$vmin;
}
sub load{
	open DATA,"$_[0]" or die "[SVGLAB.pm::load()]Can't load data form file $_[0].\n";
	my @line;
	my @M;#讀入的矩陣
	while(<DATA>){
		if(/^#/){
			next;
		}else{
			@line=split /[\s\,]+/;
			push @M,[@line];
		}
	}
	if($#M==0){
		@M=@{$M[0]};#若一行,退化為行向量,即一維引用[x1,x2,...,xn]
	}
	[@M];
=c	返回形式為:
	[	[X11,X12,...,X1n],
		[X21,X22,...,X2n],
		...
		[Xm1,Xm2,...,Xmn]	],矩陣
	或
	[x1,x2,...,xn],向量
=cut
}

sub cal_colours{
#以下典型顏色値來自:
#http://hi.baidu.com/flysnows/blog/item/722884583f4e34db9c8204d7.html
my $colour_string='1 白色 #FFFFFF
2 红色 #FF0000
3 绿色 #00FF00
4 蓝色 #0000FF
5 牡丹红 #FF00FF
6 青色 #00FFFF
7 黄色 #FFFF00
8 黑色 #000000
9 海蓝 #70DB93
10 巧克力色 #5C3317
11 蓝紫色 #9F5F9F
12 黄铜色 #B5A642
13 亮金色 #D9D919
14 棕色 #A67D3D
15 青铜色 #8C7853
16 2号青铜色 #A67D3D
17 士官服蓝色 #5F9F9F
18 冷铜色 #D98719
19 铜色 #B87333
20 珊瑚红 #FF7F00
21 紫蓝色 #42426F
22 深棕 #5C4033
23 深绿 #2F4F2F
24 深铜绿色 #4A766E
25 深橄榄绿 #4F4F2F
26 深兰花色 #9932CD
27 深紫色 #871F78
28 深石板蓝 #6B238E
29 深铅灰色 #2F4F4F
30 深棕褐色 #97694F
32 深绿松石色 #7093DB
33 暗木色 #855E42
34 淡灰色 #******
35 土灰玫瑰红色 #856363
36 长石色 #D19275
37 火砖色 #8E2323
38 森林绿 #238E23
39 金色 #CD7F32
40 鲜黄色 #DBDB70
41 灰色 #C0C0C0
42 铜绿色 #527F76
43 青黄色 #93DB70
44 猎人绿 #215E21
45 印度红 #4E2F2F
46 土黄色 #9F9F5F
47 浅蓝色 #C0D9D9
48 浅灰色 #A8A8A8
49 浅钢蓝色 #8F8FBD
59 浅木色 #E9C2A6
60 石灰绿色 #32CD32
61 桔黄色 #E47833
62 褐红色 #8E236B
63 中海蓝色 #32CD99
64 中蓝色 #3232CD
65 中森林绿 #6B8E23
66 中鲜黄色 #EAEAAE
67 中兰花色 #9370DB
68 中海绿色 #426F42
69 中石板蓝色 #7F00FF
70 中春绿色 #7FFF00
71 中绿松石色 #70DBDB
72 中紫红色 #DB7093
73 中木色 #A68064
74 深藏青色 #2F2F4F
75 海军蓝 #23238E
76 霓虹篮 #4D4DFF
77 霓虹粉红 #FF6EC7
78 新深藏青色 #00009C
79 新棕褐色 #EBC79E
80 暗金黄色 #CFB53B
81 橙色 #FF7F00
82 橙红色 #FF2400
83 淡紫色 #DB70DB
84 浅绿色 #8FBC8F
85 粉红色 #BC8F8F
86 李子色 #EAADEA
87 石英色 #D9D9F3
88 艳蓝色 #5959AB
89 鲑鱼色 #6F4242
90 猩红色 #BC1717
91 海绿色 #238E68
92 半甜巧克力色 #6B4226
93 赭色 #8E6B23
94 银色 #E6E8FA
95 天蓝 #3299CC
96 石板蓝 #007FFF
97 艳粉红色 #FF1CAE
98 春绿色 #00FF7F
99 钢蓝色 #236B8E
100 亮天蓝色 #38B0DE
101 棕褐色 #DB9370
102 紫红色 #D8BFD8
103 石板蓝色 #ADEAEA
104 浓深棕色 #5C4033
105 淡浅灰色 #CDCDCD
106 紫罗兰色 #4F2F4F
107 紫罗兰红色 #CC3299
108 麦黄色 #D8D8BF
109 黄绿色 #99CC32'; 
	foreach(split /\n/,$colour_string){
		if(/(#\w+)/){
			push @COLOURS,$1;
		}
	}
}
1;#為了取消如是錯誤:"SVGLAB.pm did not return a true value at ...";蓋若某模塊衹有子過程而無代碼,編譯不通過.


