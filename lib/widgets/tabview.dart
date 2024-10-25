import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/common/color_constants.dart';


/*
Title:TabBarWidget
Purpose:TabBarWidget
Created By:Kalpesh Khandla
Created Date:17 Feb 2021
*/

class _TabBarWidgetState extends State<TabBarView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20,left: 15,right: 15,),
          child: Column(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),
                    color: ColorConstants.kBlueColor,
                  ),
                  labelColor: ColorConstants.kWhiteColor,
                  unselectedLabelColor: ColorConstants.kBlackColor,
                  tabs: const [
                    Tab(
                      text: 'Yesterday',
                    ),
                    Tab(
                      text: 'Today',
                    ),
                      Tab(
                      text: 'Tomorrow',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                   Padding(
                     padding: EdgeInsets.only(top: 10),
                     child: Column(
                       children: [
                         Text("Tab1"),
                       ],
                     ),
                   ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Text("Tab2"),
                        ],
                      ),
                    ),
                     Padding(
                       padding: EdgeInsets.only(top: 10),
                       child: Column(
                         children: [
                           Text("Tab3"),
                         ],
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}