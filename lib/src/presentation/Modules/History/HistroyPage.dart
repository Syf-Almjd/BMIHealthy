import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../config/utils/managers/app_constants.dart';
import '../../../config/utils/styles/app_colors.dart';
import '../../../data/local/localData_cubit/local_data_cubit.dart';
import '../../Ads/ad_helper.dart';
import '../../../domain/bmi_entry.dart';
import '../../Shared/Components.dart';
import 'BmiChart.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> prevBMI = [];
  bool isLoaded = false;

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    getLocalData();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  getAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AD_LOAD_FAILED code=${err.code} msg=${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  getLocalData() async {
    var items = await LocalDataCubit.get(context)
        .getSharedDataList(AppConstants.previousBmiList);
    if (!mounted) return;
    setState(() {
      prevBMI = items;
      isLoaded = true;
    });
    // Only request a banner when the screen has real content to show.
    if (items.isNotEmpty && _bannerAd == null) getAd();
  }

  @override
  Widget build(BuildContext context) {
    final bannerVisible = _bannerAd != null && prevBMI.isNotEmpty;
    final chartValues = prevBMI
        .map((e) => BmiEntry.parse(e).value)
        .whereType<double>()
        .toList();
    if (chartValues.length > 30) {
      chartValues.removeRange(0, chartValues.length - 30);
    }
    final content = ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getCube(1, context),
              Text(
                "History",
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: getWidth(10, context)),
                textAlign: TextAlign.left,
              ),
              Text(
                "Swipe to remove..",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: getWidth(4, context)),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        if (chartValues.length >= 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: BmiChart(values: chartValues),
          ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Visibility(
              visible: isLoaded,
              replacement: Center(
                child: (prevBMI.isEmpty
                    ? const Text("There are no saved History!")
                    : const CircularProgressIndicator()),
              ),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height - 300.0,
                  child: listData()),
            )),
      ],
    );
    if (!bannerVisible) return content;
    // The banner sits below the scrolling history, above the bottom navigation,
    // with its real height reserved so it is never cut off.
    return Column(
      children: [
        Expanded(child: content),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: adWidget(),
          ),
        ),
      ],
    );
  }

  Widget listData() {
    return ListView.builder(
      padding: const EdgeInsets.all(25),
      physics: const BouncingScrollPhysics(),
      reverse: true,
      itemCount: prevBMI.length,
      itemBuilder: (context, index) => getDataList(index),
    );
  }

  getDataList(index) {
    if (index < prevBMI.length) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Dismissible(
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.redColor.withOpacity(0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "Delete",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              showToast("Deleted Successfully", context);
              LocalDataCubit.get(context).deleteSharedItem(
                  AppConstants.previousBmiList, prevBMI[index]);
              setState(() {
                prevBMI.remove(prevBMI[index]);
              });
            }
          },
          direction: DismissDirection.endToStart,
          key: Key(prevBMI[index]),
          child: BMIInfoTile(
            entry: BmiEntry.parse(prevBMI[index]),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget adWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

class BMIInfoTile extends StatelessWidget {
  const BMIInfoTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final BmiEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Add a slight elevation for a card-like appearance
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Apply rounded corners
      ),
      child: ListTile(
        onTap: () async {
          showToast("BMI was Copied! ${entry.valueText}", context);
          await Clipboard.setData(ClipboardData(text: entry.valueText));
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        subtitle: entry.dateLabel == null ? null : Text(entry.dateLabel!),
        title: Text(
          entry.valueText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.spoke_outlined),
      ),
    );
  }
}
