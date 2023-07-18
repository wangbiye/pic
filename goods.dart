
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'bean/shopReceiveBean.dart';
import 'spellShopOrder.dart';
import 'package:core/base/widget/iconfont.dart';
import 'package:YHWMS/locationSetting/yh_screen_util.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:YHWMS/utils/alert_utils.dart';

class ShopReceive extends BaseFlutterWidget {
  @override
  getFlutterState() {
    return ShopReceiveState();
  }
}

class ShopReceiveState extends BaseAppBarState<ShopReceive>
    implements ShopReceiveView {
  ShopReceivePresenter presenter;
  RefreshController _refreshController =RefreshController(initialRefresh: false);

  ShopReceiveBean data;

  int pageindex = 1;
  String overdueAutoCancellation = "";

  @override
  bool get isWhiteTheme => true;

  @override
  double get elevation => 0.0;

  @override
  Text buildAppbarTitle() {
    return Text("小店间领用");
  }

  @override
  void initState() {
    presenter = ShopReceivePresenter(this);
    super.initState();
    getOverdueAutoCancellation();
    // initData();
  }

  getOverdueAutoCancellation() async{
    overdueAutoCancellation =  await presenter.getOverdueAutoCancellation();
  }

  initData() async {
    data = await presenter.getData(10, 1);
    if(data != null){
      pageindex = 1;
      _refreshController.resetNoData();
      _refreshController.loadComplete();
    }
  }

  @override
  void onResume(){
    super.onResume();

    initData();
  }

  void _onLoading() async {
    pageindex = pageindex + 1;
    if (!(pageindex > data.totalpage)) {
      ShopReceiveBean order = await presenter.getData(10, pageindex);
      setState(() {
        data.rows.addAll(order.rows);
      });
    }

    pageindex > data.totalpage
        ? _refreshController.loadNoData()
        : _refreshController.loadComplete();
  }

  @override
  Widget buildBody() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints){
      return Column(
        children: [
          (overdueAutoCancellation != null
              && overdueAutoCancellation != ""
              && overdueAutoCancellation != "0") ? Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFE9E5),
            ),
            padding: EdgeInsets.fromLTRB(YHScreenUtil.setWidth(18), YHScreenUtil.setWidth(10), YHScreenUtil.setWidth(16), YHScreenUtil.setWidth(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: IconFontWms(IconFonts.WARNING_FULL, color: Color(0xFFFA5740), size: YHScreenUtil.setSp(20)),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '超过$overdueAutoCancellation小时未提交会被自动作废',
                        style: TextStyle(color: Color(0xFFFA5740), fontSize: 14)),
                  ]),
                ),
              ],
            ),
          ) : Container(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: YHScreenUtil.setWidth(18), vertical: YHScreenUtil.setWidth(10)),
            child: InkWell(
              onTap: (){
                NavigationUtil.pushPage(context, SpellShopOrder());
              },
              child: Container(
                color: Color(0xFFF0F7FF),
                width: viewportConstraints.maxHeight,
                padding: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: GlobalColors.primaryColor,
                      size: YHScreenUtil.setWidth(30),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: '新建领用单',
                            style: TextStyle(color: GlobalColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: data != null && data.rows != null && data.rows.length > 0
                ? SmartRefresher(
                enablePullDown: false,
                enablePullUp: true,
                header: ClassicHeader(
                  height: 45.0,
                  releaseText: '松开手刷新',
                  refreshingText: '刷新中',
                  completeText: '刷新完成',
                  failedText: '刷新失败',
                  idleText: '下拉刷新',
                ),
                controller: _refreshController,
                // onRefresh: _onRefresh,
                onLoading: _onLoading,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text(" ");
                    } else if (mode == LoadStatus.loading) {
                      body = Text(" ");
                    } else if (mode == LoadStatus.failed) {
                      body = Text(" ");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text(" ");
                    } else {
                      body = Text("没有更多数据！");
                    }
                    return Container(
                      height: 20,
                      child: Center(child: body),
                    );
                  },
                ),
                child: ListView.builder(itemBuilder: _itemBuilder, itemCount: data.rows.length,)) : Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    height: 12,
                    color: Color(0xFFF5F7FC),
                  ),
                  SizedBox(
                    height: YHScreenUtil.setWidth(80),
                  ),
                  Image.asset("assets/imgs/location_setting_blank.png",
                      width: YHScreenUtil.setWidth(180),
                      height: YHScreenUtil.setWidth(120),
                      fit: BoxFit.contain),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: '暂无领用单',
                          style: TextStyle(color: Color(0xFFAAAFB9), fontSize: 14)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 列表 item
  Widget _itemBuilder(BuildContext context, int position) {
    final item = data.rows[position];
    return Container(
      margin: position == 0 ? EdgeInsets.only(top: 10, bottom: 10) : EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: Key(item.attributetransno),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) {
                YHAlertUtils.showAlertDialog(context, "确定要作废当前领用单吗？", null, "取消", "确定", (alertContext) {
                  Navigator.pop(alertContext);
                }, (alertContext) async {
                  Navigator.pop(alertContext);
                  Map<String,dynamic> json = await presenter.deleteBill(item.id);
                  if(json != null){
                    toast('领用单已作废成功');
                    initData();
                  }
                });
              },
              backgroundColor: Color(0xFFFA5740),
              foregroundColor: Colors.white,
              label: '作废',
              // padding: EdgeInsets.only(right: 20),
            ),
          ],
        ),
        child: InkWell (
          onTap: () {
            NavigationUtil.pushPage(context, SpellShopOrder(orderData: item));
          },
          child: Container(
            color: Colors.white,
            child: Padding(padding: EdgeInsets.symmetric(horizontal: YHScreenUtil.setWidth(18), vertical: YHScreenUtil.setWidth(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: LRNText('单号 ', '${item.attributetransno ?? ""}', leftColor: Colors.black, fontSize: 16,)
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${item.createdbyname ?? ""}',
                                style: TextStyle(color: Color(0xFF3C7AF7), fontSize: 14)),
                          ]),
                        )
                      ],
                    ),
                    SizedBox(height: YHScreenUtil.setWidth(8),),
                    LRNText('创建时间 ', '${DateUtil.formatByNum(item.createdat ?? 0, formatRule: 'yyyy-MM-dd HH:mm:ss')}', leftColor: Color(0xFF838B98), rightColor: Color(0xFF2B354A), fontSize: 14,),
                    SizedBox(height: YHScreenUtil.setWidth(8),),
                    Container(
                      padding: EdgeInsets.only(top: YHScreenUtil.setWidth(12), bottom: YHScreenUtil.setWidth(12)),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F7FC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: YHScreenUtil.setWidth(6), right: YHScreenUtil.setWidth(6)),
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text: '${item.fromworkshopname ?? ""}',
                                        style: TextStyle(color: Color(0xFF2B354A), fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4,),
                                RichText(
                                  text: TextSpan(
                                      text: '领出小店',
                                      style: TextStyle(color: Color(0xFF838B98), fontSize: 14)
                                  ),
                                ),
                              ],
                            ),),
                          Center(child: Image.asset("assets/imgs/icon_arrow_with_xiaodianjian.png",
                              width: YHScreenUtil.setWidth(54),
                              height: YHScreenUtil.setWidth(8),
                              fit: BoxFit.contain),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: YHScreenUtil.setWidth(6), right: YHScreenUtil.setWidth(6)),
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text: '${item.toworkshopname ?? ""}',
                                        style: TextStyle(color: Color(0xFF2B354A), fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4,),
                                RichText(
                                  text: TextSpan(
                                      text: '领入小店',
                                      style: TextStyle(color: Color(0xFF838B98), fontSize: 14)
                                  ),
                                ),
                              ],
                            ),),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

  @override
  void error(bool show) {}

  @override
  BuildContext getCtx() {
    return getContext();
  }

  @override
  void loading(bool show) {
    loadingViewVisible(show);
  }

  @override
  void toastByPresenter(str) {
    toast(str);
  }

}

abstract class ShopReceiveView extends BaseIView {}

class ShopReceivePresenter extends BasePresenter<ShopReceiveView> {
  ShopReceivePresenter(ShopReceiveView interface) : super(interface);
  getData(pagesize, pageindex) async {
    ShopReceiveBean jsonData;
    await post("/api/wms-inv-hub/pdaattributetrans/list", params:
    {
      "pagesize": pagesize,
      "pageindex": pageindex
    }
    ).success((json, base) {
      jsonData = json != null ? ShopReceiveBean.fromJson(json) : null;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  getOverdueAutoCancellation() async {
    RequestBaseModel response = await request("/api/wms-inv-hub/attributetrans/getoverdueautocancellationconfig",type: "WMS", method: 'POST');
    if(response == null || response.code!=0){
      return "";
    }
    return response.data;
  }

  deleteBill(String id) async {
    Map<String, dynamic> jsonData;
    await post("/api/wms-inv-hub/pdaattributetrans/cancel", params: {
      "id": id
    }).success((json, base) {
      jsonData = json;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }
}

import 'package:YHWMS/locationSetting/yh_screen_util.dart';
import 'package:core/core.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin_tms/common/utils/toastUtils.dart';
import 'bean/shopReceiveBean.dart';
import 'bean/spellShopOrderBean.dart';
import 'addGoods.dart';
import 'package:YHWMS/utils/alert_utils.dart';
import 'package:yh_pda_scanner/pda_listener_mixin.dart';
import 'package:yh_code_scanner/yh_code_scanner.dart';
import 'widget/shop_selection_button.dart';
import 'package:YHWMS/locationSetting/widget/select_item_widget.dart';
import 'package:YHWMS/shelved/widget/textFieldNew.dart';

class SpellShopOrder extends BaseFlutterWidget {
  Rows orderData;
  SpellShopOrder({this.orderData});

  @override
  getFlutterState() {
    return SpellShopOrderState();
  }
}

class SpellShopOrderState extends BaseAppBarState<SpellShopOrder>
    with PdaListenerMixin
    implements SpellShopOrderView {

  SpellShopOrderPresenter presenter;

  List<WorkShopBean> workShopList = [];

  /// 领入小店
  String _mWorkShopNameTo;
  String _mWorkShopCodeTo;
  /// 领入小店临时值, 在修改时用一下, 修改成功赋值给上边的变量
  String _mWorkShopNameToTemp;
  String _mWorkShopCodeToTemp;

  /// 领出小店
  String _mWorkShopNameFrom;
  String _mWorkShopCodeFrom;
  /// 领出小店临时值, 在修改时用一下, 修改成功赋值给上边的变量
  String _mWorkShopNameFromTemp;
  String _mWorkShopCodeFromTemp;

  /// 领出按钮
  bool shopFromSelectionButtonEnable;
  /// 领入按钮
  bool shopToSelectionButtonEnable;

  SpellShopOrderBean data;

  /// `添加商品` text field 焦点
  FocusNode addingGoodsTextFieldFocusNode = FocusNode();
  /// 列表 item TextField 管理
  List<ListItemRender> _listItemRender;

  /// 跳转切换页面之前设置为 true, 回来时控制禁止刷新; 有效一次
  bool disableRefresh = false;

  @override
  bool get isMonitorPage => true;

  @override
  bool get isInteractiveReport => true;

  @override
  bool get isInitNoRequest => true;

  @override
  bool get isWhiteTheme => true;

  @override
  double get elevation => 0.0;

  @override
  Text buildAppbarTitle() {
    return Text("填写店间领用");
  }

  @override
  void initState() {
    presenter = SpellShopOrderPresenter(this);
    super.initState();
  }

  @override
  void dispose() {
    if (_listItemRender != null && _listItemRender.length > 0) {
      for (var render in _listItemRender) {
        render.storageSpacesController.dispose();
      }
    }
    super.dispose();
  }

  // 作废功能
  List<Widget> buildAppbarActions(){
    if (widget.orderData == null || widget.orderData.id == null || widget.orderData.id.isEmpty) {
      return [];
    }
    return [
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: InkWell(
            onTap: (){
              YHAlertUtils.showAlertDialog(context, "确定要作废当前领用单吗？", null, "取消", "确定", (alertContext) {
                Navigator.pop(alertContext);
              }, (alertContext) async {
                Navigator.pop(alertContext);
                executeDeleteBill();
              });
            },
            child: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(minWidth: 40),
              child: Text("作废",style: TextStyle(fontSize: 16, color: Color(0xFF2B354A)),),
            ),
          ),),
      )
    ];
  }

  // 作废领用单
  executeDeleteBill() async {
    Map<String,dynamic> json = await presenter.deleteBill(widget.orderData.id);
    if (json != null) {
      toast('领用单已作废成功');
      Navigator.of(context).pop();
    }
  }

  initData() async {
    if (disableRefresh) {
      disableRefresh = false;
      return;
    }
    if (workShopList.length == 0) {
      String warehouseId = await Sp.getString(WAREHOUSE_ID) ?? '';
      Map<String, dynamic> map = {
        'warehouseid': warehouseId
      };
      WorkShopListBean shopList = await presenter.getWorkShopList(map);

      if (shopList != null
          && shopList.userworkshoplist != null
          && shopList.userworkshoplist.isNotEmpty
          && shopList.userworkshoplist.length > 0) {
        setState((){
          workShopList = shopList.userworkshoplist;
        });
      }
    }

    if (widget.orderData == null || widget.orderData.id == null || widget.orderData.id.isEmpty) {
      // 从新建来的, 没有 order
        // 创建一个空领用单
        Map<String, dynamic> json = await presenter.createOrder();
        if (json != null) {
          setState(() {
            widget.orderData = Rows();
            widget.orderData.attributetransno = json['attributetrasnno'];
            _mWorkShopNameTo = widget.orderData.toworkshopname;
            _mWorkShopCodeTo = widget.orderData.toworkshopcode;
            _mWorkShopNameFrom = widget.orderData.fromworkshopname;
            _mWorkShopCodeFrom = widget.orderData.fromworkshopcode;
            shopFromSelectionButtonEnable = true;
            shopToSelectionButtonEnable = true;
          });
          Future.microtask(() {
            // 在更新完成后执行某些操作
            _chooseWorkShop();
          });
        }
        // 创建空单时后续接口不需要调用了, 创建成功会再触发 initData
        return;
    } else {
      setState(() {
        _mWorkShopNameTo = widget.orderData.toworkshopname;
        _mWorkShopCodeTo = widget.orderData.toworkshopcode;
        _mWorkShopNameFrom = widget.orderData.fromworkshopname;
        _mWorkShopCodeFrom = widget.orderData.fromworkshopcode;
      });
    }

    data = await presenter.getData(widget.orderData.id);
    if (data != null) {
      Map<String, dynamic> store = {};
      data.list.forEach((item){
        String groupKey;
        if (item.skulotnorequired) {
          // 批次商品按照 fromlocationid + skucode + produceddate 分组
          groupKey = item.fromlocationid + item.skucode + item.produceddate;
        } else {
          // 非批次商品按照 fromlocationid + skucode 分组
          groupKey = item.fromlocationid + item.skucode;
        }
        if(store.keys.toList().length == 0){
          store[groupKey] = item;
          store[groupKey].listid.add(item.id);
          return;
        }
        store.keys.toList().forEach((key){
          if(key == groupKey){
            store[key].qty = (store[key].qty * 10000 + item.qty * 10000 ) / 10000;
            store[key].listid.add(item.id);
          } else {
            if(!store.containsKey(groupKey)){
              store[groupKey] = item;
              store[groupKey].listid.add(item.id);
            }
          }
        });
      });
      List<Listdata> lsitdata = [];
      store.forEach((key, value) {
        lsitdata.add(value);
      });
      _listItemRender = List.generate(lsitdata.length, (index) {
        ListItemRender render = ListItemRender();
        // render.storageSpacesFocusNode.addListener(() {
        //   if (!render.storageSpacesFocusNode.hasFocus) {
        //     // 失去焦点
        //     _listItemStorageSpacesFocusChange(index);
        //   }
        // });
        return render;
      });
      setState(() {
        data.list = lsitdata;
        shopFromSelectionButtonEnable = lsitdata.length == 0;
        shopToSelectionButtonEnable = lsitdata.length == 0;
      });
    }

  }

  deleteGoods(List<String> id) async {
    Map<String,dynamic> json = await presenter.deleteGoods(id);
    if(json != null){
      initData();
    }
  }

  executeOrder() async {
    FocusScope.of(context).unfocus();
    for (final element in _listItemRender) {
      if (element.storageSpacesError) {
        ToastUtils.showError("列表填写存在错误, 请更正后再提交");
        return;
      }
    }

    if (_mWorkShopCodeTo == '0003') {
      // 校验列表中`tolocationcode`是否有空值
      for (final element in data.list) {
        if (element.tolocationcode == null || element.tolocationcode.isEmpty) {
          ToastUtils.showError("领入储位不能为空, 请更正后再提交");
          return;
        }
      }
    }

    Map<String, dynamic> json = await presenter.executeOrder(widget.orderData.id);
    if(json != null){
      toast('执行成功');
      NavigationUtil.back(context);
    }
  }

  @override
  Widget buildBody() {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color(0xFFF5F7FC),
                // 44 是导航条高度
                height: MediaQuery.of(context).size.height - YHScreenUtil.paddingSizeTop(context) - 44 - YHScreenUtil.paddingSizeBottom(context) - YHScreenUtil.setWidth(56) - YHScreenUtil.setWidth(6) * 2,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(top: YHScreenUtil.setWidth(16), left: YHScreenUtil.setWidth(16)),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '单号 ${widget.orderData != null && widget.orderData.attributetransno != null ? widget.orderData.attributetransno : ""}',
                                  style: TextStyle(color: Color(0xFF2B354A), fontSize: 16, fontWeight: FontWeight.w600)),
                            ]),
                          ),),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(top: YHScreenUtil.setWidth(8), left: YHScreenUtil.setWidth(16), bottom: YHScreenUtil.setWidth(16), right: YHScreenUtil.setWidth(16)),
                              child: Container(
                                // margin: EdgeInsets.only(top: YHScreenUtil.setWidth(8), left: YHScreenUtil.setWidth(16), bottom: YHScreenUtil.setWidth(16), right: YHScreenUtil.setWidth(16)),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F7FC),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: ShopSelectionButton(onPressed: () {
                                        _chooseWorkShop();
                                      },
                                        enable: shopFromSelectionButtonEnable,
                                        title: _mWorkShopNameFromTemp != null ? _mWorkShopNameFromTemp : _mWorkShopNameFrom,
                                        desc: '领出小店',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // 一键切换领入领出小店
                                        if (data != null && data.list != null && data.list.length > 0) {
                                          // 列表已经有数据, 不能切换
                                          return;
                                        }
                                        if (_mWorkShopCodeTo == null || _mWorkShopCodeTo == '0' || _mWorkShopCodeFrom == null || _mWorkShopCodeFrom == '0') {
                                          ToastUtil.showToast('领入小店、领出小店不能为空');
                                          return;
                                        }
                                        setState((){
                                          _mWorkShopCodeToTemp = _mWorkShopCodeFrom;
                                          _mWorkShopNameToTemp = _mWorkShopNameFrom;
                                          _mWorkShopCodeFromTemp = _mWorkShopCodeTo;
                                          _mWorkShopNameFromTemp = _mWorkShopNameTo;
                                        });
                                        Future.microtask(() {
                                          // 在更新完成后执行某些操作
                                          _changeWorkShop();
                                        });
                                      },
                                      child: Center(
                                        child: Image.asset("assets/imgs/icon_arrow_with_xiaodianjian.png",
                                            width: YHScreenUtil.setWidth(54),
                                            height: YHScreenUtil.setWidth(54),
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: ShopSelectionButton(onPressed: () {
                                        _chooseWorkShopFrom();
                                      },
                                        enable: shopToSelectionButtonEnable,
                                        title:  _mWorkShopNameToTemp != null ? _mWorkShopNameToTemp : _mWorkShopNameTo,
                                        desc: '领入小店',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(top: YHScreenUtil.setWidth(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: YHScreenUtil.setWidth(16),),
                            Padding(
                              padding: EdgeInsets.only(left: YHScreenUtil.setWidth(16)),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: '添加商品',
                                      style: TextStyle(
                                        color: Color(0xFF2B354A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ]),
                              ),
                            ),
                            SizedBox(height: 8,),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: YHScreenUtil.setWidth(16)),
                              child: TextField(
                                focusNode: addingGoodsTextFieldFocusNode,
                                style: TextStyle(fontSize: YHScreenUtil.setSp(14.0)),
                                decoration: InputDecoration(
                                  // content 上下左右的边距, 除了控制间距, 也用来控制 text field 的高度
                                  contentPadding: EdgeInsets.only(top: YHScreenUtil.setWidth(9.0), left: YHScreenUtil.setWidth(12.0), bottom: YHScreenUtil.setWidth(9.0), right: YHScreenUtil.setWidth(12.0)),
                                  // 背景色
                                  fillColor: Color(0xFFF5F6F7),
                                  // 是否填充背景色, 不设置 fillColor 不生效
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFF5F6F7)),
                                      borderRadius: BorderRadius.circular(2)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFF5F6F7)),
                                      borderRadius: BorderRadius.circular(2)
                                  ),

                                  hintText: '输入或扫描条码 (PDA直接扫描)',
                                  hintStyle: TextStyle(fontSize: YHScreenUtil.setSp(14.0), fontWeight: FontWeight.w400, color: Color(0xFFAAAFB9)),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  suffixIcon: GestureDetector(
                                    // 防止点击穿透
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      // 防止点击 suffix icon 时进入输入状态
                                      addingGoodsTextFieldFocusNode.unfocus();
                                      addingGoodsTextFieldFocusNode.canRequestFocus = false;
                                      Future.delayed(Duration(milliseconds: 100), () {
                                        addingGoodsTextFieldFocusNode.canRequestFocus = true;
                                      });
                                      // 后续执行其他动作
                                      _scanCode();
                                    },
                                    child: Container(
                                      width: YHScreenUtil.setWidth(38.0),
                                      alignment: Alignment.center,
                                      child: Image(
                                        image: AssetImage("assets/imgs/scan_code_black.png"),
                                        color: Color(0xFF2B354A),
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  // 顶替 TextField 点击, 不让其进入输入状态
                                  // 防止点击时进入输入状态
                                  addingGoodsTextFieldFocusNode.unfocus();
                                  addingGoodsTextFieldFocusNode.canRequestFocus = false;
                                  Future.delayed(Duration(milliseconds: 100), () {
                                    addingGoodsTextFieldFocusNode.canRequestFocus = true;
                                  });
                                  if (_mWorkShopCodeTo == null || _mWorkShopCodeTo == '0' || _mWorkShopCodeFrom == null || _mWorkShopCodeFrom == '0') {
                                    ToastUtil.showToast('领入小店、领出小店不能为空');
                                    return;
                                  }
                                  NavigationUtil.pushPage(context, AddGoods(widget.orderData.id, _mWorkShopCodeFrom, _mWorkShopCodeTo));
                                },
                              ),),
                            SizedBox(height: YHScreenUtil.setWidth(16),),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: data != null && data.list != null && data.list.length > 0 ? Container(
                          padding: EdgeInsets.only(top: YHScreenUtil.setWidth(12), left: YHScreenUtil.setWidth(16), bottom: YHScreenUtil.setWidth(8)),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '领用清单 ${data.list.length}',
                                  style: TextStyle(
                                    color: Color(0xFF838B98),
                                    fontSize: 12,
                                  )),
                            ]),)
                      ) : Container(),
                    ),
                    SliverList(delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return renderItem(data.list[index], index);
                      },
                      childCount: data != null && data.list != null ? data.list.length : 0,
                    )),
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  executeOrder();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(6), horizontal: YHScreenUtil.setWidth(16)),
                  height: YHScreenUtil.setWidth(56),
                  // color: GlobalColors.primaryColor,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: GlobalColors.primaryColor,
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: '执行领用单',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            )),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
    /*
      Column(
      children: [
        Expanded(
          child: Column(
            children: [

              MySeparator(color: Colors.grey[400]),
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        Text('领出', style: TextStyle(color: Colors.black54, fontSize: 18),),
                        SizedBox(height: 5,),
                        Text('${fromCreate ? widget.orderData.fromworkshopname : widget.shopData.fromworkshopname}', style: TextStyle(color: GlobalColors.primaryColor, fontSize: 16),)
                      ],),
                      Column(children: [
                        Image.asset('assets/imgs/icon_execute_process_right.png', width: 40)
                      ],),
                      Column(children: [
                        Text('领入', style: TextStyle(color: Colors.black54, fontSize: 18),),
                        SizedBox(height: 5,),
                        Text('${fromCreate ? widget.orderData.toworkshopname : widget.shopData.toworkshopname}', style: TextStyle(color: GlobalColors.activityRed, fontSize: 16),)
                      ],),
                    ],)
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: InkWell(
                  onTap: (){
                    NavigationUtil.pushPage(context, AddGoods('${fromCreate ? widget.orderData.id : widget.shopData.id}', fromCreate ? widget.orderData.toworkshopcode : widget.shopData.toworkshopcode));
                  },
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add,
                          color: GlobalColors.primaryColor,
                          size: 30,
                        ),
                        Text('添加商品', style: TextStyle(fontSize: 16,color: GlobalColors.primaryColor,),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: data != null && data.list != null && data.list.length > 0 ? ListView.builder(
                itemBuilder: (context, index){
                  return renderItem(data.list[index]);
                },
                itemCount: data.list.length,
              ) : Container())
            ],
          ),
        ),
        InkWell(
          onTap: (){
            executeOrder();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            color: GlobalColors.primaryColor,
            child: Center(
              child: Text(
                '执行领用单',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
     */
  }

  renderItem(Listdata item, int index) {
    ListItemRender itemRender = _listItemRender[index];
    // item 中要填充领入储位
    if (item.tolocationcode != null && item.tolocationcode.isNotEmpty) {
      itemRender.storageSpacesController.text = item.tolocationcode;
    }
    if (itemRender.storageSpacesError) {
      itemRender.storageSpacesController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: itemRender.storageSpacesController.text.length,
      );
    } else {
      // 防止重新绘制时光标跑到最前边
      itemRender.storageSpacesController.selection = TextSelection.fromPosition(
        TextPosition(offset: itemRender.storageSpacesController.text.length),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: YHScreenUtil.setWidth(12)),
      padding: EdgeInsets.all(YHScreenUtil.setWidth(16)),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: (){
                  deleteGoods(item.listid);
                },
                child: Image.asset("assets/imgs/delete_icon.png",
                    width: YHScreenUtil.setWidth(20),
                    height: YHScreenUtil.setWidth(20)),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.skucode} ${item.skuname}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 16,
                      )),
                ]),
              ),
            ],
          ),
          SizedBox(height: YHScreenUtil.setWidth(4),),
          Row(
            children: [
              // 用来和第一行对齐
              SizedBox(width: YHScreenUtil.setWidth(28),),
              Container(
                  color: Color(0xFFF0F7FF),
                  padding: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(6), horizontal: YHScreenUtil.setWidth(8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: '领出储位',
                              style: TextStyle(
                                color: Color(0xFF3C7AF7),
                                fontSize: 13,

                              )),
                        ]),
                      ),
                      SizedBox(width: YHScreenUtil.setWidth(6),),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: '${item.fromlocationcode}',
                              style: TextStyle(
                                  color: Color(0xFF3C7AF7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold
                              )),
                        ]),
                      ),
                    ],
                  )
              ),
            ],
          ),
          // 生产日期
          item.skulotnorequired ? SizedBox(height: YHScreenUtil.setWidth(8),) : Container(),
          item.skulotnorequired ? Row(
            children: [
              // 用来和第一行对齐
              SizedBox(width: YHScreenUtil.setWidth(28),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '生产日期',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.produceddate}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 14,
                      )),
                ]),
              ),
            ],
          ) : Container(),
          // 领入储位
          SizedBox(height: YHScreenUtil.setWidth(8),),
          Row(
            children: [
              // 用来和第一行对齐
              SizedBox(width: YHScreenUtil.setWidth(28),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '领入储位',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              // 1. 当领入小店不是0003时，填充展示商品的拣选面，查看态，不允许修改
              // 2. 当领入小店为0003时，如商品绑定了拣选面，则默认填充进领入储位文本框，允许进行修改
              // 2.1 如商品未绑定拣选面，允许添加商品成功，领入储位为空，等待用户填写或扫描
              // 2.2 用户输入的储位，当输入完成时，需校验商品的领入小店和储位所属库区的一致性，如不满足条件，提示【XXX储位和商品XXX小店不一致，请检查！】
              _mWorkShopCodeTo != '0003' ? RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.tolocationcode}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 14,
                      )),
                ]),
              ) : Expanded(child: TextField(
                focusNode: itemRender.storageSpacesFocusNode,
                controller: itemRender.storageSpacesController,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: YHScreenUtil.setSp(14.0)),
                onChanged: (v){
                  itemRender.storageSpacesController.text = _filterString(v);
                  item.tolocationcode = v;
                  // 防止光标跑到最前边
                  itemRender.storageSpacesController.selection = TextSelection.fromPosition(
                    TextPosition(offset: itemRender.storageSpacesController.text.length),
                  );
                },
                onEditingComplete: () {
                  // 调用接口, 修改领入储位
                  _changeWorkShopTo(item, itemRender.storageSpacesController.text, itemRender);
                },
                decoration: InputDecoration(
                  // content 上下左右的边距, 除了控制间距, 也用来控制 text field 的高度
                  contentPadding: EdgeInsets.only(top: YHScreenUtil.setWidth(9.0), left: YHScreenUtil.setWidth(12.0), bottom: YHScreenUtil.setWidth(9.0), right: YHScreenUtil.setWidth(12.0)),
                  // 背景色
                  fillColor: Color(0xFFF5F6F7),
                  // 是否填充背景色, 不设置 fillColor 不生效
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF5F6F7)),
                      borderRadius: BorderRadius.circular(2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: itemRender.storageSpacesError ? BorderSide(color: Color(0xFFFA5740)) : BorderSide(color: Color(0xFFF5F6F7)),
                      borderRadius: BorderRadius.circular(2)
                  ),
                  hintText: '请扫描/输入领入储位',
                  hintStyle: TextStyle(fontSize: YHScreenUtil.setSp(14.0), fontWeight: FontWeight.w400, color: Color(0xFFAAAFB9)),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: GestureDetector(
                    // 防止点击穿透
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      disableRefresh = true;
                      // 防止点击 suffix icon 时进入输入状态
                      itemRender.storageSpacesFocusNode.unfocus();
                      itemRender.storageSpacesFocusNode.canRequestFocus = false;
                      Future.delayed(Duration(milliseconds: 100), () {
                        itemRender.storageSpacesFocusNode.canRequestFocus = true;
                      });
                      try {
                        // 此处为扫码结果，barcode为二维码的内容
                        String barcode = await YhCodeScanner.scanCode(
                          viewType: 1,
                        );
                        itemRender.storageSpacesController.text = _filterString(barcode);
                        item.tolocationcode = itemRender.storageSpacesController.text;
                        print('扫码结果: ' + barcode);
                        // 调用接口, 修改领入储位
                        _changeWorkShopTo(item, itemRender.storageSpacesController.text, itemRender);

                      } on PlatformException catch (e) {
                        if (e.code == YhCodeScanner.cameraAccessDenied) {
                          // 未授予APP相机权限
                          ToastUtil.showToast('未授予相机权限，请开启相机权限');
                        } else {
                          // 扫码错误
                          print('扫码错误: $e');
                        }
                      } on FormatException {
                        // 进入扫码页面后未扫码就返回
                        print('进入扫码页面后未扫码就返回');
                      } catch (e) {
                        // 扫码错误
                        print('扫码错误: $e');
                      } finally {

                      }
                    },
                    child: Container(
                      width: YHScreenUtil.setWidth(38.0),
                      alignment: Alignment.center,
                      child: Image(
                        image: AssetImage("assets/imgs/scan_code.png"),
                        color: Color(0xFF2B354A),
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ),),
            ],
          ),
          // 领用数量
          SizedBox(height: YHScreenUtil.setWidth(8),),
          Row(
            children: [
              // 用来和第一行对齐
              SizedBox(width: YHScreenUtil.setWidth(28),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '领用数量',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.standard ? item.qty.toStringAsFixed(0) : item.qty.toString()} ${item.unitname}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 14,
                      )),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 选择领出小店
  _chooseWorkShop() {
    if (workShopList.isEmpty) {
      return;
    }
    var dialog = SelectItemWidgetDialog(context, "领出小店", workShopList
        .asMap()
        .map((i, m) =>
        MapEntry(i, SelectedListBean(id: i, name: m.workshopname)))
        .values
        .toList(), (index, value) {
      workShopFromChooseCallBack(index);
    });
    dialog.showBottomSheet();
  }

  //选择领入小店
  _chooseWorkShopFrom(){
    if (workShopList.isEmpty) {
      return;
    }
    var dialog = SelectItemWidgetDialog(context, "领入小店", workShopList
        .asMap()
        .map((i, m) =>
        MapEntry(i, SelectedListBean(id: i, name: m.workshopname)))
        .values
        .toList(), (index, value) {
      workShopToChooseCallBack(index);
    });
    dialog.showBottomSheet();
  }

  /// 领出小店
  workShopFromChooseCallBack(int index){
    WorkShopBean bean = workShopList[index];
    String currentWorkShopCodeTo = _mWorkShopCodeToTemp != null ? _mWorkShopCodeToTemp : _mWorkShopCodeTo;
    if( bean.workshopcode == currentWorkShopCodeTo){
      toast('领出小店和领入小店不能相同，请重新选择');
      return;
    }
    setState((){
      // 修改领出小店
      _mWorkShopCodeFromTemp = bean.workshopcode;
      _mWorkShopNameFromTemp = bean.workshopname;
    });
    Future.microtask(() {
      // 在更新完成后执行某些操作
      if ((_mWorkShopCodeTo != null && _mWorkShopCodeTo != '0') || _mWorkShopCodeToTemp != null) {
        _changeWorkShop();
      }
    });
  }

  /// 领入
  workShopToChooseCallBack(int index){
    WorkShopBean bean = workShopList[index];
    String currentWorkShopCodeFrom = _mWorkShopCodeFromTemp != null ? _mWorkShopCodeFromTemp : _mWorkShopCodeFrom;
    if(bean.workshopcode == currentWorkShopCodeFrom){
      toast('领出小店和领入小店不能相同，请重新选择');
      return;
    }
    setState((){
      // 修改领入小店
      _mWorkShopCodeToTemp = bean.workshopcode;
      _mWorkShopNameToTemp = bean.workshopname;
    });
    Future.microtask(() {
      // 在更新完成后执行某些操作
      if ((_mWorkShopCodeFrom != null && _mWorkShopCodeFrom != '0') || _mWorkShopCodeFromTemp != null) {
        _changeWorkShop();
      }
    });
  }
  
  _changeWorkShop() async {
    if (_mWorkShopCodeTo == null && _mWorkShopCodeToTemp == null) {
      toast('领入小店参数不完整, 请重新选择');
      return;
    }
    if (_mWorkShopCodeFrom == null && _mWorkShopCodeFromTemp == null) {
      toast('领出小店参数不完整, 请重新选择');
      return;
    }

    Map<String, dynamic> params = {
      // 这个 id 可能会没有值, 新建时一开始没有 id
      "id": widget.orderData.id,
      "attributetransno": widget.orderData.attributetransno,
      // 注意, 参数判断三目运算都用 code 判断
      "fromworkshopcode": _mWorkShopCodeFromTemp != null ? _mWorkShopCodeFromTemp : _mWorkShopCodeFrom,
      "fromworkshopname": _mWorkShopCodeFromTemp != null ? _mWorkShopNameFromTemp : _mWorkShopNameFrom,
      "toworkshopcode": _mWorkShopCodeToTemp != null ? _mWorkShopCodeToTemp : _mWorkShopCodeTo,
      "toworkshopname": _mWorkShopCodeToTemp != null ? _mWorkShopNameToTemp : _mWorkShopNameTo
    };
    Map<String,dynamic> json = await presenter.changeWorkShop(params);
    if (json != null) {
      widget.orderData.id = json['id'];
      initData();
      // 修改成功, 修改值
      setState(() {
        if (_mWorkShopCodeFromTemp != null) {
          _mWorkShopCodeFrom = _mWorkShopCodeFromTemp;
          _mWorkShopNameFrom = _mWorkShopNameFromTemp;
          if (widget.orderData != null) {
            widget.orderData.fromworkshopname = _mWorkShopNameFromTemp;
            widget.orderData.fromworkshopcode = _mWorkShopCodeFromTemp;
          }
        }
        if (_mWorkShopCodeToTemp != null) {
          _mWorkShopCodeTo = _mWorkShopCodeToTemp;
          _mWorkShopNameTo = _mWorkShopNameToTemp;
          if (widget.orderData != null) {
            widget.orderData.toworkshopname = _mWorkShopNameToTemp;
            widget.orderData.toworkshopcode = _mWorkShopCodeToTemp;
          }
        }
        // 用完清空 setState
        _mWorkShopCodeToTemp = null;
        _mWorkShopNameToTemp = null;
        _mWorkShopCodeFromTemp = null;
        _mWorkShopNameFromTemp = null;
      });
    } else {
      // 用完清空
      _mWorkShopCodeToTemp = null;
      _mWorkShopNameToTemp = null;
      _mWorkShopCodeFromTemp = null;
      _mWorkShopNameFromTemp = null;
    }

  }

  Future _scanCode() async {
    try {
      // 此处为扫码结果，barcode为二维码的内容
      String barcode = await YhCodeScanner.scanCode(
          viewType: 1,
      );
      if (_mWorkShopCodeTo == null || _mWorkShopCodeTo == '0' || _mWorkShopCodeFrom == null || _mWorkShopCodeFrom == '0') {
        ToastUtil.showToast('领入小店、领出小店不能为空');
        return;
      }
      NavigationUtil.pushPage(context,
        AddGoods(widget.orderData.id,
          _mWorkShopCodeFrom,
          _mWorkShopCodeTo,
          defaultProductCode: barcode,),
      );
      print('扫码结果: ' + barcode);
    } on PlatformException catch (e) {
      if (e.code == YhCodeScanner.cameraAccessDenied) {
        // 未授予APP相机权限
        ToastUtil.showToast('未授予相机权限，请开启相机权限');
      } else if (e.code == YhCodeScanner.manualInput) {
        if (_mWorkShopCodeTo == null || _mWorkShopCodeTo == '0' || _mWorkShopCodeFrom == null || _mWorkShopCodeFrom == '0') {
          ToastUtil.showToast('领入小店、领出小店不能为空');
          return;
        }
        NavigationUtil.pushPage(context,
          AddGoods(widget.orderData.id,
            _mWorkShopCodeFrom,
            _mWorkShopCodeTo,),
        );
      } else {
        // 扫码错误
        print('扫码错误: $e');
      }
      // focusScopeNode.requestFocus(_commentFocus);
    } on FormatException {
      // 进入扫码页面后未扫码就返回
      print('进入扫码页面后未扫码就返回');
    } catch (e) {
      // 扫码错误
      print('扫码错误: $e');
    } finally {

    }
  }

  /// 用来过滤字符串中所有的空格和空行, 并将字母转大写
  String _filterString(String str) {
    RegExp regExp = RegExp(r'\s+'); // 匹配空格和换行符
    String result = str.replaceAll(regExp, '').toUpperCase(); // 替换为空字符串并转换为大写
    return result;
  }

  /// 修改领入储位
  _changeWorkShopTo(Listdata item, String targetShopCode, ListItemRender itemRender) async {
    if (targetShopCode == null || targetShopCode.isEmpty) {
      ToastUtil.showToast("内容不能为空");
      return;
    }
    Map<String, dynamic> params = {
      "attributetransid": widget.orderData.id,
      "tolocationcode": targetShopCode,
      "attributetransdetailidlist": item.listid
    };
    RequestBaseModel response = await presenter.changeWorkShopTo(params);
    itemRender.storageSpacesError = response == null || response.code != 0;
    if (itemRender.storageSpacesError) {
      itemRender.storageSpacesController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: itemRender.storageSpacesController.text.length,
      );
      ToastUtil.showToast(response.message);
      itemRender.storageSpacesFocusNode.requestFocus();
    } else {
      itemRender.storageSpacesFocusNode.unfocus();
    }
  }

  @override
  void onEvent(Object code) {
    // 响应 pda 扫码
    if (code != null) {
      if (_mWorkShopCodeTo == null || _mWorkShopCodeTo == '0' || _mWorkShopCodeFrom == null || _mWorkShopCodeFrom == '0') {
        ToastUtil.showToast('领入小店、领出小店不能为空');
        return;
      }
      NavigationUtil.pushPage(context, AddGoods(widget.orderData.id, _mWorkShopCodeFrom, _mWorkShopCodeTo, defaultProductCode: code.toString().trim(),));
    }
  }

  @override
  void error(bool show) {}

  @override
  BuildContext getCtx() {
    return getContext();
  }

  @override
  void loading(bool show) {
    loadingViewVisible(show);
  }

  @override
  void toastByPresenter(str) {
    toast(str);
  }

  @override
  void onResume() {
    initData();
    // TODO: implement onResume
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }
}

abstract class SpellShopOrderView extends BaseIView {}

class SpellShopOrderPresenter extends BasePresenter<SpellShopOrderView> {

  SpellShopOrderPresenter(BaseIView interface) : super(interface);

  createOrder() async {
    Map<String, dynamic> jsonData;
    await post('/api/wms-inv-hub/pdaattributetrans/generatorattributetransno').success((map, module) {
      jsonData = map;
    }).failed((e) {

    }).request();
    return jsonData;
  }

  getData(String attributetransid) async {
    SpellShopOrderBean jsonData;
    await post("/api/wms-inv-hub/pdaattributetransdetail/list", params: {
      "attributetransid": attributetransid
    }).success((json, base) {
      jsonData = (json != null) ? SpellShopOrderBean.fromJson(json) : null ;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  executeOrder(String id) async {
    Map<String, dynamic> jsonData;
    await post("/api/wms-inv-hub/pdaattributetrans/exectattributetrans", params: {
      "id": id
    }).success((json, base) {
      jsonData = json;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  deleteGoods(List<String> id) async {
    Map<String, dynamic> jsonData;
    await post("/api/wms-inv-hub/pdaattributetransdetail/batchdelete", params: {
      "ids": id
    }).success((json, base) {
      jsonData = json;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  deleteBill(String id) async {
    Map<String, dynamic> jsonData;
    await post("/api/wms-inv-hub/pdaattributetrans/cancel", params: {
      "id": id
    }).success((json, base) {
      jsonData = json;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  getWorkShopList(params) async {
    WorkShopListBean bean;
    await post(API_GET_WORK_SHOP_LIST, params: params)
        .successList((map,module){
      bean = WorkShopListBean.fromJson(map);
    })
        .failed((e) {})
        .request();
    return bean;
  }

  /// 修改领入领出小店
  changeWorkShop(params) async {
    Map<String, dynamic> jsonData;
    await post("/api/wms-inv-hub/pdaattributetrans/changeattributetransworkshop", params: params).success((json, base) {
      jsonData = json;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  /// 修改领入储位
  changeWorkShopTo(params) async {
    RequestBaseModel response = await request('/api/wms-inv-hub/pdaattributetransdetail/padupdateattributetranstolocation',
        type: 'WMS',
        method: 'POST',
        showError: false,
        showLoading: false,
        params: params);
    return response;
  }

  /// 修改领用数量
  modifyQuantityAmount(params) async {
    RequestBaseModel response = await request('/api/wms-inv-hub/attributetransdetail/updateattributetransqty',
        type: 'WMS',
        method: 'POST',
        showError: false,
        showLoading: false,
        params: params);
    return response;
  }

}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 3.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

/// 用来管理列表上的 TextField
class ListItemRender {

  /// 储位
  FocusNode storageSpacesFocusNode = FocusNode();
  TextEditingController storageSpacesController = TextEditingController();
  /// 储位错误标记, 如果为 true, TextField 会包裹红圈并全选文字
  bool storageSpacesError = false;

  ListItemRender();

}

import 'dart:async';

import 'package:core/core.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:yh_pda_scanner/pda_listener_mixin.dart';
import 'package:flutter/services.dart';
import 'bean/addGoodsBean.dart';
import 'package:YHWMS/locationSetting/yh_screen_util.dart';
import 'package:yh_code_scanner/yh_code_scanner.dart';
import 'package:core/base/widget/iconfont.dart';

class AddGoods extends BaseFlutterWidget {
  final String companyid;
  final String attributetransid;
  final String fromworkshopcode;
  final String toworkshopcode;
  /// 默认商品 code, 直接 set 进搜索框, 并执行搜索
  final String defaultProductCode;
  AddGoods(this.attributetransid, this.fromworkshopcode, this.toworkshopcode, {this.companyid, this.defaultProductCode});

  @override
  getFlutterState() {
    return AddGoodsState();
  }
}

class AddGoodsState extends BaseAppBarState<AddGoods>
    with PdaListenerMixin, WidgetsBindingObserver
    implements AddGoodsView {

  AddGoodsPresenter presenter;
  AddGoodsBean data;

  /// 顶部搜索框
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchInputController = TextEditingController();
  /// 列表 item TextField 管理
  List<ListItemRender> _listItemRender;
  /// 按钮到屏幕底部的间距
  double _marginBottom = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  bool get isWhiteTheme => true;

  @override
  double get elevation => 0.0;

  @override
  Text buildAppbarTitle() {
    return Text("添加商品");
  }

  @override
  void initState() {
    if (widget.defaultProductCode != null) {
      searchInputController.text = widget.defaultProductCode;
    } else {
      searchFocusNode.requestFocus();
    }
    presenter = AddGoodsPresenter(this);
    super.initState();
    // 注册键盘监听器
    WidgetsBinding.instance.addObserver(this);
    initData();
  }

  // 在组件重新构建时，调用 dispose 方法清空文本控制器
  @override
  void dispose() {
    if (_listItemRender != null && _listItemRender.length > 0) {
      for (var render in _listItemRender) {
        render.productionDateController.dispose();
        render.amountController.dispose();
      }
    }
    // 移除键盘监听器
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  initData() async {
    if (searchInputController.text == null || searchInputController.text.isEmpty) {
      // 没有 defaultProductCode, 不执行后续搜索
      return;
    }
    data = await presenter.getData(searchInputController.text, widget.companyid, widget.fromworkshopcode, widget.attributetransid);
    if (data != null && data.list != null && data.list.length == 0) {
      toast('该商品暂无可用库存记录');
    }
    if (data != null && data.list != null && data.list.length > 0) {
      _listItemRender = List.generate(data.list.length, (index) {
        ListItemRender render = ListItemRender();
        return render;
      });
    }
  }

  @override
  void didChangeMetrics() {
    // 监听键盘弹出和收起事件
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset == 0) {
      // 键盘收起
      setState(() {
        _marginBottom = YHScreenUtil.paddingSizeBottom(context) + YHScreenUtil.setWidth(6);
      });
    } else {
      // 键盘弹出
      setState(() {
        _marginBottom = 0;
      });
    }
  }

  @override
  Widget buildBody() {
    if (_marginBottom == -1) {
      _marginBottom = YHScreenUtil.paddingSizeBottom(context) + YHScreenUtil.setWidth(6);
    }

    return GestureDetector(
      onTap: () {
        // 点击空白区域使 TextField 失去焦点
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Expanded(child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: YHScreenUtil.setWidth(16), vertical: YHScreenUtil.setWidth(6)),
                color: Colors.white,
                child:  TextField(
                  autocorrect: false,
                  focusNode: searchFocusNode,
                  controller: searchInputController,
                  style: TextStyle(fontSize: YHScreenUtil.setSp(14.0)),
                  textInputAction: TextInputAction.search,
                  keyboardType: Platform.isIOS ? TextInputType.numberWithOptions(signed: true, decimal: true) : TextInputType.number,
                  onSubmitted: (value) {
                    // 处理确定操作
                    initData();
                  },
                  decoration: InputDecoration(
                    // content 上下左右的边距, 除了控制间距, 也用来控制 text field 的高度
                    contentPadding: EdgeInsets.only(top: YHScreenUtil.setWidth(9.0), left: YHScreenUtil.setWidth(12.0), bottom: YHScreenUtil.setWidth(9.0), right: YHScreenUtil.setWidth(12.0)),
                    // 背景色
                    fillColor: Color(0xFFF5F6F7),
                    // 是否填充背景色, 不设置 fillColor 不生效
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF5F6F7)),
                        borderRadius: BorderRadius.circular(2)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF5F6F7)),
                        borderRadius: BorderRadius.circular(2)
                    ),

                    hintText: '请输入/扫描商品码',
                    hintStyle: TextStyle(fontSize: YHScreenUtil.setSp(14.0), fontWeight: FontWeight.w400, color: Color(0xFFAAAFB9)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Container(
                      width: YHScreenUtil.setWidth(38.0),
                      alignment: Alignment.center,
                      child: Image(
                        image: AssetImage("assets/imgs/search-blue.png"),
                        color: Color(0xFFAAAFB9),
                        width: 16,
                        height: 16,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        searchFocusNode.hasFocus ? GestureDetector(
                          // 防止点击穿透
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // 后续执行其他动作
                            searchInputController.clear();
                            setState(() {
                              data = null;
                            });
                          },
                          child: Container(
                            width: YHScreenUtil.setWidth(38.0),
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage("assets/imgs/new_clear_con.png"),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ) : Container(),
                        GestureDetector(
                          // 防止点击穿透
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // 防止点击 suffix icon 时进入输入状态
                            searchFocusNode.unfocus();
                            searchFocusNode.canRequestFocus = false;
                            Future.delayed(Duration(milliseconds: 100), () {
                              searchFocusNode.canRequestFocus = true;
                            });
                            // 后续执行其他动作
                            _searchScanCode();
                          },
                          child: Container(
                            width: YHScreenUtil.setWidth(38.0),
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage("assets/imgs/scan_code_black.png"),
                              color: Color(0xFF2B354A),
                              width: 24,
                              height: 24,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: data != null && data.list != null && data.list.length > 0 ?
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: data != null && data.message != ""
                            ?
                        data.extinfo == '100001'
                        // 红色提示
                            ? Container(
                          padding: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(10), horizontal: YHScreenUtil.setWidth(16)),
                          color: Color(0xFFFFE9E5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: IconFontWms(IconFonts.WARNING_FULL, color: Color(0xFFFA5740), size: YHScreenUtil.setSp(20)),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: '${data?.message}',
                                        style: TextStyle(color: Color(0xFFFA5740), fontSize: 14)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        )
                        // 黄色提示
                            : Row(
                          children: [
                            Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(10), horizontal: YHScreenUtil.setWidth(16)),
                                  color: Color(0xFFFFF7E8),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: '${data?.message}',
                                          style: TextStyle(
                                            color: Color(0xFFFF7D00),
                                            fontSize: 14,
                                          )),
                                    ]),
                                  ),
                                )
                            )
                          ],
                        ) : Container(),
                      ),
                      SliverList(delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return renderItem(data.list[index], index);
                        },
                        childCount: data != null && data.list != null ? data.list.length : 0,
                      )),
                    ],
                  ) : Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(
                          height: YHScreenUtil.setWidth(80),
                        ),
                        Image.asset("assets/imgs/location_setting_blank.png",
                            width: YHScreenUtil.setWidth(180),
                            height: YHScreenUtil.setWidth(120),
                            fit: BoxFit.contain),
                      ],
                    ),
                  )),
            ],
          ),),
          data != null && data.list != null && data.list.length > 0 ? InkWell(
            onTap: (){
              execute();
            },
            child: Container(
              height: YHScreenUtil.setWidth(56),
              margin: EdgeInsets.only(top: YHScreenUtil.setWidth(6), left: YHScreenUtil.setWidth(16), bottom: _marginBottom, right: YHScreenUtil.setWidth(16)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: GlobalColors.primaryColor,
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '确定',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )),
                  ]),
                ),
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }

  renderItem(ListData item, int index) {
    ListItemRender itemRender = _listItemRender[index];
    if (item.moveQty != null && item.moveQty > 0) {
      itemRender.amountController.text = item.standard ? item.moveQty.toStringAsFixed(0) : item.moveQty.toString();
    }
    if (itemRender.amountError) {
      itemRender.amountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: itemRender.amountController.text.length,
      );
      itemRender.amountFocusNode.requestFocus();
    } else {
      // 防止重新绘制时光标跑到最前边
      itemRender.amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: itemRender.amountController.text.length > 0 ? itemRender.amountController.text.length : 0),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: YHScreenUtil.setWidth(12)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.skuname}',
                      style: TextStyle(
                          color: Color(0xFF2B354A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      )),
                ]),
              ),
            ],
          ),
          SizedBox(height: YHScreenUtil.setWidth(4),),
          Row(children: [
            Container(
                color: Color(0xFFF0F7FF),
                padding: EdgeInsets.symmetric(vertical: YHScreenUtil.setWidth(6), horizontal: YHScreenUtil.setWidth(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: '领出储位',
                            style: TextStyle(
                              color: Color(0xFF3C7AF7),
                              fontSize: 13,

                            )),
                      ]),
                    ),
                    SizedBox(width: YHScreenUtil.setWidth(6),),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: '${item.locationcode}',
                            style: TextStyle(
                                color: Color(0xFF3C7AF7),
                                fontSize: 13,
                                fontWeight: FontWeight.bold
                            )),
                      ]),
                    ),
                  ],
                )
            ),
          ],),
          // 可用数量
          SizedBox(height: YHScreenUtil.setWidth(8),),
          Row(
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '可用数量',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${StringUtil.delDecimalPoint(item.usableqty.toString()) ?? ""}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 14,
                      )),
                ]),
              ),
            ],
          ),
          // 生产日期
          item.skulotnorequired && item.produceddate != null && item.produceddate.isNotEmpty ? SizedBox(height: YHScreenUtil.setWidth(8),) : Container(),
          item.skulotnorequired && item.produceddate != null && item.produceddate.isNotEmpty ? Row(
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '生产日期',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${item.produceddate}',
                      style: TextStyle(
                        color: Color(0xFF2B354A),
                        fontSize: 14,
                      )),
                ]),
              ),
            ],
          ) : Container(),
          // 领用数量
          SizedBox(height: YHScreenUtil.setWidth(8),),
          Row(
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '转移数量',
                      style: TextStyle(
                        color: Color(0xFF838B98),
                        fontSize: 14,
                      )),
                ]),
              ),
              SizedBox(width: YHScreenUtil.setWidth(8),),
              Expanded(
                child: TextField(
                  focusNode: itemRender.amountFocusNode,
                  controller: itemRender.amountController,
                  style: TextStyle(fontSize: YHScreenUtil.setSp(14.0)),
                  inputFormatters: [
                    // `标品`不能输入小数
                    !item.standard ? FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.)?[0-9]{0,3}')) : FilteringTextInputFormatter.allow(RegExp("[1-9][0-9]*")),
                  ],
                  keyboardType: Platform.isIOS ? TextInputType.numberWithOptions(signed: true, decimal: true) : TextInputType.number,
                  onChanged: (v){
                    if(v == ""){
                      item.moveQty = 0;
                      return;
                    }
                    try {
                      item.moveQty = num.parse(v);
                      itemRender.amountError = item.moveQty > item.usableqty;
                    } catch (e) {
                      toast('输入错误');
                    }
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    // content 上下左右的边距, 除了控制间距, 也用来控制 text field 的高度
                    contentPadding: EdgeInsets.only(top: YHScreenUtil.setWidth(5.0), left: YHScreenUtil.setWidth(12.0), bottom: YHScreenUtil.setWidth(5.0), right: YHScreenUtil.setWidth(12.0)),
                    // 背景色
                    fillColor: Color(0xFFF5F6F7),
                    // 是否填充背景色, 不设置 fillColor 不生效
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: itemRender.amountError ? BorderSide(color: Color(0xFFFA5740)) : BorderSide(color: Color(0xFFF5F6F7)),
                        borderRadius: BorderRadius.circular(2)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: itemRender.amountError ? BorderSide(color: Color(0xFFFA5740)) : BorderSide(color: Color(0xFFF5F6F7)),
                        borderRadius: BorderRadius.circular(2)
                    ),
                    hintText: '请填写转移数量',
                    hintStyle: TextStyle(fontSize: YHScreenUtil.setSp(14.0), fontWeight: FontWeight.w400, color: Color(0xFFAAAFB9)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: itemRender.amountError ? GestureDetector(
                      // 防止点击穿透
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        itemRender.amountController.clear();
                        item.moveQty = 0;
                        itemRender.amountError = false;
                      },
                      child: Container(
                        width: YHScreenUtil.setWidth(38.0),
                        alignment: Alignment.center,
                        child: Image(
                          image: AssetImage("assets/imgs/new_clear_con.png"),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ) : Container(width: 0,),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Container(
      margin: EdgeInsets.only(top: YHScreenUtil.setWidth(12)),
      color: Colors.white,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.skuname ?? ""}', style: TextStyle(fontSize: 16,)),
            SizedBox(height: 5,),
            LRNText('商品储位：', '${item.locationname ?? ""}'),
            SizedBox(height: 5,),
            LRNText('可用数量：', '${StringUtil.delDecimalPoint(item.usableqty.toString()) ?? ""}'),
            SizedBox(height: 5,),
            Row(children: [
              Text('转移数量：', style: TextStyle(color: Colors.black54, fontSize: 15),),
              Expanded(child:
              TextField(
                // 将文本控制器绑定到 TextField
                controller: itemRender.amountController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 7,horizontal: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1.0,
                    ),
                  ),
                ),
                inputFormatters: [
                  // `标品`不能输入小数
                  !item.standard ? FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.)?[0-9]{0,3}')) : FilteringTextInputFormatter.allow(RegExp("[1-9][0-9]*")),
                ],
                keyboardType: Platform.isIOS ? TextInputType.numberWithOptions(signed: true, decimal: true) : TextInputType.number,
                onChanged: (v){
                  if(v == ""){
                    item.moveQty = 0;
                    return;
                  }
                  try {
                    item.moveQty = num.parse(v);
                  } catch (e) {
                    toast('输入错误');
                  }
                },
                textInputAction: TextInputAction.next,
              )
              ),
            ],)
          ],),
      ),
    );
  }

  Future _searchScanCode() async {
    try {
      // 此处为扫码结果，barcode为二维码的内容
      String barcode = await YhCodeScanner.scanCode(
        viewType: 0,
      );
      searchInputController.text = barcode;
      initData();
      print('扫码结果: ' + barcode);
    } on PlatformException catch (e) {
      if (e.code == YhCodeScanner.cameraAccessDenied) {
        // 未授予APP相机权限
        ToastUtil.showToast('未授予相机权限，请开启相机权限');
      } else {
        // 扫码错误
        print('扫码错误: $e');
      }
      // focusScopeNode.requestFocus(_commentFocus);
    } on FormatException {
      // 进入扫码页面后未扫码就返回
      print('进入扫码页面后未扫码就返回');
    } catch (e) {
      // 扫码错误
      print('扫码错误: $e');
    } finally {

    }
  }

  /// `确定`添加商品
  execute() async {
    Map<String, dynamic> params = {
      "inventoryslist": [],
      "attributetransid": widget.attributetransid,
    };
    for (int i = 0; i < data.list.length; i++) {
      ListData item = data.list[i];
      if(item.moveQty == null || item.moveQty == 0) {
        continue;
      }
      // if (item.moveQty > item.usableqty) {
      //   // 超过了可用数量
      //   ListItemRender itemRender = _listItemRender[i];
      //   setState(() {
      //     itemRender.amountError = true;
      //   });
      //   return;
      // }
      Map<String, dynamic> itemParams = {
        "inventoryid": item.multiinventoryids.split(":")[0],
        "locationname": item.locationname,
        "multiinventoryids": item.multiinventoryids,
        "qty": item.moveQty,
        "skucode": item.skucode,
        "produceddate": item.produceddate,
        "skulotnorequired": item.skulotnorequired,
      };
      params["inventoryslist"].add(itemParams);
    }

    if(params["inventoryslist"].length == 0){
      toast('请添加商品明细');
      return;
    }

    CoreHttpBaseModel json = await presenter.submitAdd(params);
    if(json != null && json.code == 0){
      toast('添加成功');
      NavigationUtil.back(context);
    }
  }

  @override
  void onError(Object error) {
    // TODO: implement onError
  }

  @override
  void onEvent(Object code) {
    if (code != null) {
      // 响应 pda 扫码
      searchInputController.text = code.toString().trim();
      initData();
    }
  }

  @override
  void error(bool show) {}

  @override
  BuildContext getCtx() {
    return getContext();
  }

  @override
  void loading(bool show) {
    loadingViewVisible(show);
  }

  @override
  void toastByPresenter(str) {
    toast(str);
  }

  @override
  void onResume() {
    // TODO: implement onResume
  }

}

abstract class AddGoodsView extends BaseIView {}

class AddGoodsPresenter extends BasePresenter<AddGoodsView> {
  AddGoodsPresenter(AddGoodsView interface) : super(interface);
  getData(String skucode, String companyid, String workshopcode, String attributetransid) async {
    AddGoodsBean jsonData;
    await post("/api/wms-inv-hub/pdaattributetransdetail/getinventorys", params: {
      "skucode": skucode,
      "companyid": companyid,
      "workshopcode": workshopcode,
      "datacombine": true,
      "attributetransid": attributetransid
    }).success((json, base) {
      jsonData = json != null ? AddGoodsBean.fromJson(json) : null;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }

  submitAdd(params) async {
    CoreHttpBaseModel jsonData;
    await post("/api/wms-inv-hub/pdaattributetransdetail/batchsave", params: params).success((json, base) {
      jsonData = base;
    }).failed((e) {
      interface.loading(false);
    }).onFinal(() {
      interface.loading(false);
    }).request();
    return jsonData;
  }
}

/// 用来管理列表上的 TextField
class ListItemRender {

  /// 生产日期
  FocusNode productionDateFocusNode = FocusNode();
  TextEditingController productionDateController = TextEditingController();
  /// 转移数量
  FocusNode amountFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  /// 数量填写错误标记
  bool amountError = false;

}

import 'package:YHWMS/locationSetting/yh_screen_util.dart';
import 'package:core/core.dart';

/// 小店间转移新建时门店选择按钮
class ShopSelectionButton extends StatefulWidget {

  final bool enable;
  final String title;
  final VoidCallback onPressed;
  final String desc;

  ShopSelectionButton({this.onPressed, this.enable, this.title = "请选择", this.desc});

  @override
  _ShopSelectionButtonState createState() => _ShopSelectionButtonState();

}

class _ShopSelectionButtonState extends State<ShopSelectionButton> {

  final Widget icon = ColorFiltered(
    colorFilter: ColorFilter.mode(Color(0xFF2B354A), BlendMode.srcIn),
    child: Image.asset("assets/imgs/icon_arrow_up.png", width: 18, height: 18,),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enable != null && widget.enable ? widget.onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(top: YHScreenUtil.setWidth(12), left: YHScreenUtil.setWidth(6), bottom: YHScreenUtil.setWidth(12), right: YHScreenUtil.setWidth(6)),
        // onPressed: widget.enable != null && widget.enable ? widget.onPressed : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    flex: 1,
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text:  widget.title ?? "请选择",
                            style: TextStyle(
                              color: widget.title != null ? Color(0xFF2B354A) : Color(0xFFAAAFB9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )
                        )
                    )
                ),
                widget.enable != null && widget.enable ? SizedBox(width: 9,) : Container(),
                widget.enable != null && widget.enable ? icon : Container(),
              ],
            ),
            SizedBox(height: 4,),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: widget.desc,
                    style: TextStyle(color: Color(0xFF838B98), fontSize: 14)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

}
