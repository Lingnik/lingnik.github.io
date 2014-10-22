# Use <!--adsense1--> or <!--adsense2--> in markdown content files
module Jekyll
  module AdsenseFilter
    ADSENSE = {
      :ccfl1 => %Q{
<div style="margin:20px 0;">
<script type="text/javascript"><!--
google_ad_client = "pub-0538590636658555";
/* 728x15 CCFL #1, created 7/27/08 */
google_ad_slot = "9355648463";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
},
      :ccfl2 => %Q{
<div style="margin:20px 0;">
<script type="text/javascript"><!--
google_ad_client = "pub-0538590636658555";
/* 728x90 CCFL #2, created 7/27/08 */
google_ad_slot = "5486029204";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
},
      :ccfl3 => %Q{
<div style="margin:20px 0;">
<script type="text/javascript"><!--
google_ad_client = "pub-0538590636658555";
/* 728x90 CCFL #3, created 7/27/08 */
google_ad_slot = "9678562132";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
},
      :ccfl4 => %Q{
<div style="margin:20px 0;">
<script type="text/javascript"><!--
google_ad_client = "pub-0538590636658555";
/* 728x15 CCFL #4, created 7/27/08 */
google_ad_slot = "2360833618";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
}
    }

    def adsense_replace(input)
      output = input
        .gsub(/<!--adsense-ccfl1-->/, ADSENSE[:ccfl1])
        .gsub(/<!--adsense-ccfl2-->/, ADSENSE[:ccfl2])
        .gsub(/<!--adsense-ccfl3-->/, ADSENSE[:ccfl3])
        .gsub(/<!--adsense-ccfl4-->/, ADSENSE[:ccfl4])
      output
    end

  end
end

Liquid::Template.register_filter(Jekyll::AdsenseFilter)