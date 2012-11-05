# bluid html from markdown
# it's for https://github.com/progit/progit
# git://github.com/progit/progit.git
# install markdown
# 2012-06-07
# bakup old file
# 2011-06-10 orignally by opengit.org , 19:13 2012/3/12 modified by 荒野无灯
# changelog: 修改了下css字体和html DOCTYPE,增加对windows支持。
# put the file in / of object
 

if [ $# -ne 1 ]; then
    read -p 'put a language shortname：' lang
else
    lang=$1
fi
out=progit_$lang.html
if [ -f progit_$lang.html ];then
    mv progit_$lang.html progit_$lang.html.`date +%Y%m%d%H%M%S`.bak
fi
echo $lang
echo $out
touch $out
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css"><!--body{margin:0 20px;font-size:14px;font-family:"Microsoft YaHei","WenQuanYi ZenHei";}pre{margin:1em 0;font-size:13px;background-color:#eee;border:1px solid #ddd;padding:5px;line-height:1.5em;color:#444;overflow:auto;border-radius:3px;}code{background:#eee;}pre,code{font-family:"Deja Vu Sans Mono",Consolas,Monaco,"Courier New",Courier,monospace;}h1{text-align:center;margin-top:30px;color:green}h2{color:#6EA2F8}h3{color:#EE7D2F}.page{border:2px solid #333;background:#333;margin: 30px 0;}img{max-width:600px;display:block;text-align:center;border-radius:5px;}--></style>
	</head><body>' >> $out
#make a table 
echo "<table> <td>" >> $out
for i in `ls $lang/`
    do 
    list=`find $lang/$i -iname "*.markdown"`
    #html=$lang/${i/\//\.html}
    html=$lang/$i/$i.html
    #uncomment below for Linux	
    #markdown -v -o 'html4' $list -f $html
    #for windows
    php htmlscripts/markdown.php $list $html
    cat $html >> $out
    rm $html
    echo '<div class="page"></div>' >> $out
    echo "get $list; markdown2html add to $out"
done
echo '</td><td style="vertical-align:top; text-align:top;"><!--TableOfContents:Begin-->There is TableOfContents<!--TableOfContents:End--></td>' >> $out;
echo '</body></html>' >> $out;


#add by gdbdzgd insert image and put image in the center for zh only
echo  -n "Inserting Image ."
grep  "Insert [0-9]*[a-z]*[0-9]*" -o  $out |while read f
do
	echo -n "."
	sed -i  "s/${f}.png/<img src=\"figures\/${f##Insert }-tn.png\" \/>/g" $out
done

echo ""
echo "adjust Image in the middle"
sed -i  "/[0-9]*[a-z]*[0-9]*-tn.png/i <div align=\"center\"> " $out
sed -i  "/^图 [0-9]*-[0-9]*\.\|^Figure [0-9]*-[0-9]*\./a </div>" $out

echo "make html Toc Contens..."
perl htmlscripts/HtmlHeadingsToTableOfContents.pl $out 2>/dev/null

echo 'add button "返回顶部"'
sed -i '/<\/head>/i<style type="text/css">\n\t#floater{\n\t\tword-break:break-all;\n\t\tposition:fixed;\n\t\tfont-size:20%;\n\t\t_position:absolute;\n\t\tright:20px;\n\t\tbottom:20px;\n\t\tbackground:white;\n\t}\n </style>' $out 
sed -i '/<body>/a<div>\n <a name="top"> \n<h1 id="floater"><a href="#header">^返回顶部<\/a><\/h1>\n <\/div>\n <A NAME="header"><\/A>\n' $out
