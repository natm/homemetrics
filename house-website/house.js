// globals
var currentperiod='';
var periods = { "1min":"4 hour", "5min": "day"};
var cameras = { "frontdoor":"Front door","feeder1":"Dog feeder 1","feeder2":"Dog feeder 2"};
var ppoints_max = 30;
var updatesin = 0;
var updatestmr = 15;
var updates = 0;
var dataobj;
var cfgobj = {
	"sensors": [
		{	"type"	: "power",	"key"	: "powertotal",		"title" : "Power",		"suffix": "watts",	"points": []	},
/*		{	"type"	: "temp",	"key"	: "10369B9E000800E1",	"title" : "Outside",		"suffix": "&#8451",     "points": [],	"dec": "2"  	},*/
		{	"type"  : "temp",	"key"	: "10A4679E000800B9",	"title" : "Lounge",		"suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "107D7B9E000800B6",   "title" : "Understairs",     	"suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "283E809E0300003B",   "title" : "Master bedroom",     "suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "2859A69A03000017",   "title" : "Airing cupboard",    "suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "28B67F9E030000B9",   "title" : "Loft study",     	"suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "28B7739E030000AF",   "title" : "loft eaves front", 	"suffix": "&#8451",     "points": [],	"dec": "2"       },
                {       "type"  : "temp",       "key"   : "28688E9E03000005",   "title" : "Loft eaves rear", 	"suffix": "&#8451",	"points": [],	"dec": "2"       }
	]
};


function startUp()
{
	$('.blink').blink();

	loadGraphs('5min');

	for (cam in cameras)
	{
		var id = "#cam" + cam;
		$(id).mouseover(function()
		{
			$(this).css("cursor","pointer");
			(this).width=320;
		});
		$(id).mouseout(function()
		{
			(this).width=160;
		});
	}

	// cameras refresh every minute
	$("body").everyTime(60000,'timerRefreshCameras',function() { loadCameras(); });
	loadCameras();

	setupLive();

	$("body").everyTime(1000,'timerRefreshLive',function() { timerRefreshLive(); });
//	timerRefreshLive();
}

function setupLive()
{
	var html = "";

        for (var i = 0; i < cfgobj.sensors.length; i++) {
                var sensor = cfgobj.sensors[i];
                var idtitle = "livet_" + sensor.key;
                var idvalue = "livev_" + sensor.key;
		var idchange = "livec_" + sensor.key;
                var idspark = "lives_" + sensor.key;
		html = html + "<span class=livetitle id=" + idtitle + ">" + sensor.title + " </span>";
		html = html + "<span class=livevalue id=" + idvalue + "></span>";
		html = html + "<span class=livechange id=" + idchange + "></span>";
		html = html + "<span class=inlinesparkline id=" + idspark + "></span>";
		html = html + "<br/ clear=all>";
	}
	$("#livelist").html(html);

	for (var i = 0; i < cfgobj.sensors.length; i++) {
                var sensor = cfgobj.sensors[i];
                var idspark = "lives_" + sensor.key;
		$("#" + idspark).sparkline(sensor.points);	
	}
}

function timerRefreshLive()
{
	if (updates > 1) {
        	$('.blink').hide();
	}
	$("#updatesin").html(updatesin);
	if (updatesin == 0) {
		updatesin = updatestmr;

		$.ajax({
			url: "/jsonget/",
			cache: false,
			dataType: 'json',
			async: false,
			success: function(data) {
				dataobj = data;
			}
		});
//		alert(dataobj.data.length);

	        for (var i = 0; i < cfgobj.sensors.length; i++) {
        	        var sensor = cfgobj.sensors[i];
			var idvalue = "livev_" + sensor.key;
			var idchange = "livec_" + sensor.key;
	                var idspark = "lives_" + sensor.key;
			var data;
			for (var d = 0; d < dataobj.data.length; d++) {
				if (dataobj.data[d].key == sensor.key) {
					data = dataobj.data[d].value;
				}
			}
			if (typeof(data) == "undefined") {
				$("#" + idvalue).html("");
			} else {

			
		                        sensor.valnow = data;
					$("#" + idvalue).html(sensor.valnow + " " + sensor.suffix);
					if (typeof(sensor.vallast) != "undefined")
					{
						var difftext = "";
						var diff = sensor.valnow - sensor.vallast;
						if (typeof(sensor.dec) != "undefined") {
							diff = diff.toFixed(sensor.dec);
						}
					        var cssweight = "";
		                                var csscolor = "";
						if (diff == 0)  {
		                                        // no change
		                                        difftext = "NC";
                		                        cssweight = "normal";
                                		        csscolor = "blue";
		                                }
                		                if (diff > 0) {
                                		        // increase
		                                        difftext = "+" + diff;
		                                        cssweight = "bold";
		                                        csscolor = "red";
		                                }
		                                if (diff < 0) {
		                                        // decrease
		                                        difftext = diff;
               		 	                       cssweight = "bold";
                                		        csscolor = "green";
		                                }
						$("#" + idchange).html(difftext);
						$("#" + idchange).css('color',csscolor);
		                                $("#" + idchange).css("font-weight",cssweight)
					}
					sensor.vallast = sensor.valnow;
		                        sensor.points.push(sensor.valnow);
		                        if (sensor.points.length > ppoints_max) {
                		                sensor.points.splice(0,1);
		                        }
		                        $("#" + idspark).sparkline(sensor.points);					
			}				
		}
		updates++;
	} else {
		updatesin--;
	}
}

function loadCameras()
{
	d = new Date();
        for (cam in cameras)
        {
                var id = "#cam" + cam;
		var img = "/cameras/" + cam + ".jpg?" +d.getTime();
		$(id).attr("src", img);
	}
}

function periodSelect(period)
{
	loadGraphs(period);
}

function loadGraphs(period)
{
	loadGraph(period,'power_total');
	loadGraph(period,'temp_combhouse');
	loadGraph(period,'temp_boiler');
	loadGraph(period,'temp_loft');
	loadGraph(period,'net_internet');
	loadGraph(period,'net_wifiusers');
}

function loadGraph(period,id)
{
	var file = id + '_' + period + '.png';
	var h = "<img src='/graphs/" + file + "'>";
	$("#" + id).html(h);
}
