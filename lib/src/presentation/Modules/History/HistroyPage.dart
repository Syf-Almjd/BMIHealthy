import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/utils/managers/app_constants.dart';
import '../../../config/utils/styles/app_colors.dart';
import '../../../data/local/localData_cubit/local_data_cubit.dart';
import '../../Shared/Components.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> prevBMI = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    getLocalData();
  }

  getLocalData() async {
    var items = await LocalDataCubit.get(context)
        .getSharedDataList(AppConstants.previousBmiList);
    setState(() {
      prevBMI = items;
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ))
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
            label: prevBMI[index],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class BMIInfoTile extends StatelessWidget {
  const BMIInfoTile({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Add a slight elevation for a card-like appearance
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Apply rounded corners
      ),
      child: ListTile(
        onTap: () async {
          showToast("BMI was Copied! $label", context);
          await Clipboard.setData(ClipboardData(text: label));
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          label,
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
