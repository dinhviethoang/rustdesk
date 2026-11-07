// original cm window in Sciter version.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common/widgets/audio_input.dart';
import 'package:flutter_hbb/common/widgets/cyber_widgets.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/widgets/tabbar_widget.dart';
import 'package:flutter_hbb/models/chat_model.dart';
import 'package:flutter_hbb/models/cm_file_model.dart';
import 'package:flutter_hbb/utils/platform_channel.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common.dart';
import '../../common/widgets/chat_page.dart';
import '../../models/file_model.dart';
import '../../models/platform_model.dart';
import '../../models/server_model.dart';

/// Set only by this window's own close control, and only once the user has confirmed. Any other
/// way the window can go - a session logout closing every window, the window manager, a native
/// title-bar button this app does not draw - leaves it false, which is the honest answer:
/// nothing in that close says who asked for it. It lives at file scope because the control that
/// sets it (`ConnectionManagerState`) and the handler that reads it (`_DesktopServerPageState`)
/// are different widgets.
bool _cmClosedByOperator = false;

class DesktopServerPage extends StatefulWidget {
  const DesktopServerPage({Key? key}) : super(key: key);

  @override
  State<DesktopServerPage> createState() => _DesktopServerPageState();
}

class _DesktopServerPageState extends State<DesktopServerPage>
    with WindowListener, AutomaticKeepAliveClientMixin {
  final tabController = gFFI.serverModel.tabController;

  _DesktopServerPageState() {
    gFFI.ffiModel.updateEventListener(gFFI.sessionId, "");
    Get.put<DesktopTabController>(tabController);
    tabController.onRemoved = (_, id) {
      onRemoveId(id);
    };
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    // Other platforms keep the old behaviour exactly: the ambiguity this guards against is a
    // Linux session logout, which closes every window in the session.
    final byOperator = _cmClosedByOperator || !isLinux;
    Future.wait([gFFI.serverModel.closeAll(byOperator: byOperator), gFFI.close()]).then((_) {
      if (isMacOS) {
        RdPlatformChannel.instance.terminate();
      } else {
        windowManager.setPreventClose(false);
        windowManager.close();
      }
    });
    super.onWindowClose();
  }

  void onRemoveId(String id) {
    if (tabController.state.value.tabs.isEmpty) {
      windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gFFI.serverModel),
        ChangeNotifierProvider.value(value: gFFI.chatModel),
      ],
      child: Consumer<ServerModel>(
        builder: (context, serverModel, child) {
          final body = Scaffold(
            backgroundColor: const Color(0xFF04070B),
            body: Stack(
              children: [
                const Positioned.fill(
                  child: CyberGridBackground(
                    gridSize: 20.0,
                    backgroundColor: Color(0xFF04070B),
                    gridColor: Color(0x1F00E5FF),
                  ),
                ),
                ConnectionManager(),
                const Positioned.fill(
                  child: CyberScanLine(),
                ),
              ],
            ),
          );
          return isLinux
              ? buildVirtualWindowFrame(context, body)
              : workaroundWindowBorder(
                  context,
                  Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: const Color(0xFF12303A))),
                    child: body,
                  ));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ConnectionManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ConnectionManagerState();
}

class ConnectionManagerState extends State<ConnectionManager>
    with WidgetsBindingObserver {
  final RxBool _controlPageBlock = false.obs;
  final RxBool _sidePageBlock = false.obs;

  ConnectionManagerState() {
    gFFI.serverModel.tabController.onSelected = (client_id_str) {
      final client_id = int.tryParse(client_id_str);
      if (client_id != null) {
        final client =
            gFFI.serverModel.clients.firstWhereOrNull((e) => e.id == client_id);
        if (client != null) {
          gFFI.chatModel.changeCurrentKey(MessageKey(client.peerId, client.id));
          if (client.unreadChatMessageCount.value > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              client.unreadChatMessageCount.value = 0;
              gFFI.chatModel.showChatPage(MessageKey(client.peerId, client.id));
            });
          }
          windowManager.setTitle(getWindowNameWithId(client.peerId));
          gFFI.cmFileModel.updateCurrentClientId(client.id);
        }
      }
    };
    gFFI.chatModel.isConnManager = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!allowRemoteCMModification()) {
        shouldBeBlocked(_controlPageBlock, null);
        shouldBeBlocked(_sidePageBlock, null);
      }
    }
  }

  @override
  void initState() {
    gFFI.serverModel.updateClientState();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverModel = Provider.of<ServerModel>(context);
    pointerHandler(PointerEvent e) {
      if (serverModel.cmHiddenTimer != null) {
        serverModel.cmHiddenTimer!.cancel();
        serverModel.cmHiddenTimer = null;
        debugPrint("CM hidden timer has been canceled");
      }
    }

    return serverModel.clients.isEmpty
        ? Column(
            children: [
              buildTitleBar(),
              Expanded(
                child: Center(
                  child: Text(
                    translate("Waiting"),
                    style: TextStyle(
                      color: const Color(0xFF5C7A86),
                      fontFamily: MyTheme.monoFontFamily,
                      fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                      letterSpacing: 2.5,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
        : Listener(
            onPointerDown: pointerHandler,
            onPointerMove: pointerHandler,
            child: DesktopTab(
              showTitle: false,
              showMaximize: false,
              showMinimize: true,
              showClose: true,
              onWindowCloseButton: handleWindowCloseButton,
              controller: serverModel.tabController,
              selectedBorderColor: const Color(0xFF00E5FF),
              selectedTabBackgroundColor: const Color(0xFF070D14),
              unSelectedTabBackgroundColor: Colors.transparent,
              maxLabelWidth: 100,
              tail: null, //buildScrollJumper(),
              tabBuilder: (key, icon, label, themeConf) {
                final client = serverModel.clients
                    .firstWhereOrNull((client) => client.id.toString() == key);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      margin: const EdgeInsets.only(right: 6.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Tooltip(
                      message: key,
                      waitDuration: const Duration(seconds: 1),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: const Color(0xFF00E5FF),
                          fontSize: 11.0,
                          letterSpacing: 1.5,
                          fontFamily: MyTheme.monoFontFamily,
                          fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                          fontWeight: FontWeight.w600,
                        ),
                        child: label,
                      ),
                    ),
                    unreadMessageCountBuilder(client?.unreadChatMessageCount)
                        .marginOnly(left: 4),
                  ],
                );
              },
              pageViewBuilder: (pageView) => LayoutBuilder(
                builder: (context, constrains) {
                  var borderWidth = 0.0;
                  if (constrains.maxWidth >
                      kConnectionManagerWindowSizeClosedChat.width) {
                    borderWidth = kConnectionManagerWindowSizeOpenChat.width -
                        constrains.maxWidth;
                  } else {
                    borderWidth = kConnectionManagerWindowSizeClosedChat.width -
                        constrains.maxWidth;
                  }
                  if (borderWidth < 0 || borderWidth > 50) {
                    borderWidth = 0;
                  }
                  final realClosedWidth =
                      kConnectionManagerWindowSizeClosedChat.width -
                          borderWidth;
                  final realChatPageWidth =
                      constrains.maxWidth - realClosedWidth;
                  final row = Row(children: [
                    if (constrains.maxWidth >
                        kConnectionManagerWindowSizeClosedChat.width)
                      Consumer<ChatModel>(
                          builder: (_, model, child) => SizedBox(
                                width: realChatPageWidth,
                                child: allowRemoteCMModification()
                                    ? buildSidePage()
                                    : buildRemoteBlock(
                                        child: buildSidePage(),
                                        block: _sidePageBlock,
                                        mask: true),
                              )),
                    SizedBox(
                        width: realClosedWidth,
                        child: SizedBox(
                            width: realClosedWidth,
                            child: allowRemoteCMModification()
                                ? pageView
                                : buildRemoteBlock(
                                    child: _buildKeyEventBlock(pageView),
                                    block: _controlPageBlock,
                                    mask: false,
                                  ))),
                  ]);
                  return Container(
                    color: Colors.transparent,
                    child: row,
                  );
                },
              ),
            ),
          );
  }

  Widget buildSidePage() {
    final selected = gFFI.serverModel.tabController.state.value.selected;
    if (selected < 0 || selected >= gFFI.serverModel.clients.length) {
      return Offstage();
    }
    final clientType = gFFI.serverModel.clients[selected].type_();
    if (clientType == ClientType.file) {
      return _FileTransferLogPage();
    } else {
      return ChatPage(type: ChatPageType.desktopCM);
    }
  }

  Widget _buildKeyEventBlock(Widget child) {
    return ExcludeFocus(child: child, excluding: true);
  }

  Widget buildTitleBar() {
    return SizedBox(
      height: kDesktopRemoteTabBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _AppIcon(),
          Expanded(
            child: GestureDetector(
              onPanStart: (d) {
                windowManager.startDragging();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(
            width: 4.0,
          ),
          const _CloseButton()
        ],
      ),
    );
  }

  Widget buildScrollJumper() {
    final offstage = gFFI.serverModel.clients.length < 2;
    final sc = gFFI.serverModel.tabController.state.value.scrollController;
    return Offstage(
        offstage: offstage,
        child: Row(
          children: [
            ActionIcon(
                icon: Icons.arrow_left, iconSize: 22, onTap: sc.backward),
            ActionIcon(
                icon: Icons.arrow_right, iconSize: 22, onTap: sc.forward),
          ],
        ));
  }

  Future<bool> handleWindowCloseButton() async {
    var tabController = gFFI.serverModel.tabController;
    final connLength = tabController.length;
    if (connLength <= 1) {
      _cmClosedByOperator = true;
      windowManager.close();
      return true;
    } else {
      final bool res;
      if (!option2bool(kOptionEnableConfirmClosingTabs,
          bind.mainGetLocalOption(key: kOptionEnableConfirmClosingTabs))) {
        res = true;
      } else {
        res = await closeConfirmDialog();
      }
      if (res) {
        // After the dialog, never before it: an external close while it is open must not
        // inherit an intent the user had not expressed yet.
        _cmClosedByOperator = true;
        windowManager.close();
      }
      return res;
    }
  }
}

Widget buildConnectionCard(Client client) {
  return Consumer<ServerModel>(
    builder: (context, value, child) => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      key: ValueKey(client.id),
      children: [
        _CmHeader(client: client),
        const SizedBox(height: 10.0),
        client.type_() == ClientType.file ||
                client.type_() == ClientType.portForward ||
                client.type_() == ClientType.terminal ||
                client.disconnected
            ? const SizedBox()
            : _PrivilegeBoard(client: client),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _CmControlPanel(client: client),
          ),
        )
      ],
    ).paddingSymmetric(vertical: 8.0, horizontal: 8.0),
  );
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: loadIcon(30),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        windowManager.close();
      },
      icon: const Icon(
        Icons.close,
        size: 16,
        color: Color(0xFF5C7A86),
      ),
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}

class _CmHeader extends StatefulWidget {
  final Client client;

  const _CmHeader({Key? key, required this.client}) : super(key: key);

  @override
  State<_CmHeader> createState() => _CmHeaderState();
}

class _CmHeaderState extends State<_CmHeader>
    with AutomaticKeepAliveClientMixin {
  Client get client => widget.client;

  final _time = 0.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (client.authorized && !client.disconnected) {
        _time.value = _time.value + 1;
      }
    });
    // Call onSelected in post frame callback, since we cannot guarantee that the callback will not call setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gFFI.serverModel.tabController.onSelected?.call(client.id.toString());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Color dotColor;
    final String statusText;
    if (client.authorized) {
      if (client.disconnected) {
        dotColor = const Color(0xFFFF3B5C);
        statusText = translate("Disconnected").toUpperCase();
      } else {
        dotColor = const Color(0xFF00FF9F);
        statusText = 'LINKED';
      }
    } else {
      dotColor = const Color(0xFFFFB020);
      statusText = '${translate("Request access to your device")}...'.toUpperCase();
    }

    return CyberFrame(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientAvatar(),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.name.toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFFCFF8FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                        fontFamily: MyTheme.monoFontFamily,
                        fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2.0),
                    CyberLabel(
                      "NODE ${client.peerId}",
                      fontSize: 9.0,
                      letterSpacing: 2.2,
                      color: const Color(0xFF5C7A86),
                    ),
                    if (client.type_() == ClientType.terminal)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: CyberLabel(
                          translate("Terminal"),
                          fontSize: 9.0,
                          letterSpacing: 1.5,
                          color: const Color(0xFF5C7A86),
                        ),
                      ),
                    if (client.type_() == ClientType.file)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: CyberLabel(
                          translate("Transfer file"),
                          fontSize: 9.0,
                          letterSpacing: 1.5,
                          color: const Color(0xFF5C7A86),
                        ),
                      ),
                    if (client.type_() == ClientType.camera)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: CyberLabel(
                          translate("View camera"),
                          fontSize: 9.0,
                          letterSpacing: 1.5,
                          color: const Color(0xFF5C7A86),
                        ),
                      ),
                    if (client.portForward.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: CyberLabel(
                          "PORT: ${client.portForward}",
                          fontSize: 9.0,
                          letterSpacing: 1.5,
                          color: const Color(0xFF5C7A86),
                        ),
                      ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        CyberPulsingDot(color: dotColor),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: dotColor,
                              fontSize: 11.0,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: MyTheme.monoFontFamily,
                              fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (client.authorized && !client.disconnected)
                          Obx(
                            () => Text(
                              formatDurationToTime(
                                Duration(seconds: _time.value),
                              ),
                              style: TextStyle(
                                color: const Color(0xFF00E5FF),
                                fontSize: 11.0,
                                fontFamily: MyTheme.monoFontFamily,
                                fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !client.authorized ||
                    (client.type_() != ClientType.remote &&
                        client.type_() != ClientType.file &&
                        client.type_() != ClientType.camera),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: _buildChatButton(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildKeyValueRow('CIPHER', 'E2E', hasBorder: true),
          _buildKeyValueRow('ROUTE', 'DIRECT', hasBorder: false),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildClientAvatar() {
    return CyberCutBox(
      width: 54.0,
      height: 54.0,
      cut: 8.0,
      twoCorners: true,
      borderColor: const Color(0xFF00E5FF),
      backgroundColor: const Color(0x1400E5FF),
      glow: true,
      child: buildAvatarWidget(
            avatar: client.avatar,
            size: 54.0,
            borderRadius: 0,
            fallback: _buildInitialAvatar(),
          ) ??
          _buildInitialAvatar(),
    );
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00E5FF),
          fontSize: 26.0,
          fontFamily: MyTheme.monoFontFamily,
          fontFamilyFallback: MyTheme.monoFontFamilyFallback,
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return Obx(() {
      final unread = client.unreadChatMessageCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          CyberIcon(
            icon: client.type_() == ClientType.file
                ? Icons.folder_outlined
                : Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF00E5FF),
            tooltip: translate(
                client.type_() == ClientType.file ? "Transfer file" : "Chat"),
            onTap: () => checkClickTime(client.id, () {
              if (client.type_() == ClientType.file) {
                gFFI.chatModel.toggleCMFilePage();
              } else {
                gFFI.chatModel
                    .toggleCMChatPage(MessageKey(client.peerId, client.id));
              }
            }),
          ),
          if (unread > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3B5C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildKeyValueRow(String key, String value, {bool hasBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFF12303A),
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CyberLabel(
            key,
            fontSize: 9.0,
            letterSpacing: 2.2,
            color: const Color(0xFF5C7A86),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.0,
              color: const Color(0xFF00E5FF),
              fontWeight: FontWeight.w400,
              fontFamily: MyTheme.monoFontFamily,
              fontFamilyFallback: MyTheme.monoFontFamilyFallback,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivilegeBoard extends StatefulWidget {
  final Client client;

  const _PrivilegeBoard({Key? key, required this.client}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PrivilegeBoardState();
}

class _PrivilegeBoardState extends State<_PrivilegeBoard> {
  late final client = widget.client;

  Widget _buildPermissionItem({
    required bool enabled,
    required IconData iconData,
    required String label,
    required String tooltipText,
    required bool canModify,
    required Function(bool)? onTap,
  }) {
    final activeColor = const Color(0xFF00E5FF);
    final inactiveColor = const Color(0xFF5C7A86);
    final borderColor =
        enabled ? const Color(0x8C00E5FF) : const Color(0xFF12303A);
    final bgColor =
        enabled ? const Color(0x1400E5FF) : Colors.transparent;
    final iconColor = enabled ? activeColor : inactiveColor;
    final labelColor = enabled ? activeColor : inactiveColor;

    return Tooltip(
      message: "$tooltipText: ${enabled ? "ON" : "OFF"}",
      waitDuration: Duration.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CyberCutBox(
            width: 46.0,
            height: 46.0,
            cut: 6.0,
            twoCorners: true,
            borderColor: borderColor,
            backgroundColor: bgColor,
            glow: enabled,
            onTap: canModify
                ? () => checkClickTime(
                    widget.client.id, () => onTap?.call(!enabled))
                : null,
            child: Icon(
              iconData,
              size: 20.0,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8.0,
              letterSpacing: 1.4,
              color: labelColor,
              fontWeight: FontWeight.w600,
              fontFamily: MyTheme.monoFontFamily,
              fontFamilyFallback: MyTheme.monoFontFamilyFallback,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canModifyPermission =
        bind.mainGetBuildinOption(key: kOptionEnablePermChangeInAcceptWindow) !=
            'N';

    final List<Widget> items = client.type_() == ClientType.camera
        ? [
            _buildPermissionItem(
              enabled: client.audio,
              iconData: Icons.volume_up_outlined,
              label: 'AUDIO',
              tooltipText: translate('Enable audio'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "audio", enabled: enabled);
                setState(() {
                  client.audio = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.recording,
              iconData: Icons.videocam_outlined,
              label: 'REC',
              tooltipText: translate('Enable recording session'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "recording", enabled: enabled);
                setState(() {
                  client.recording = enabled;
                });
              },
            ),
          ]
        : [
            _buildPermissionItem(
              enabled: client.keyboard,
              iconData: Icons.keyboard_outlined,
              label: 'INPUT',
              tooltipText: translate('Enable keyboard/mouse'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "keyboard", enabled: enabled);
                setState(() {
                  client.keyboard = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.clipboard,
              iconData: Icons.assignment_outlined,
              label: 'CLIP',
              tooltipText: translate('Enable clipboard'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "clipboard", enabled: enabled);
                setState(() {
                  client.clipboard = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.audio,
              iconData: Icons.volume_up_outlined,
              label: 'AUDIO',
              tooltipText: translate('Enable audio'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "audio", enabled: enabled);
                setState(() {
                  client.audio = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.file,
              iconData: Icons.upload_file_outlined,
              label: 'FILES',
              tooltipText: translate('Enable file copy and paste'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "file", enabled: enabled);
                setState(() {
                  client.file = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.restart,
              iconData: Icons.restart_alt,
              label: 'REBOOT',
              tooltipText: translate('Enable remote restart'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "restart", enabled: enabled);
                setState(() {
                  client.restart = enabled;
                });
              },
            ),
            _buildPermissionItem(
              enabled: client.recording,
              iconData: Icons.videocam_outlined,
              label: 'REC',
              tooltipText: translate('Enable recording session'),
              canModify: canModifyPermission,
              onTap: (enabled) {
                bind.cmSwitchPermission(
                    connId: client.id, name: "recording", enabled: enabled);
                setState(() {
                  client.recording = enabled;
                });
              },
            ),
            if (isWindows)
              _buildPermissionItem(
                enabled: client.blockInput,
                iconData: Icons.block,
                label: 'BLOCK',
                tooltipText: translate('Enable blocking user input'),
                canModify: canModifyPermission,
                onTap: (enabled) {
                  bind.cmSwitchPermission(
                      connId: client.id,
                      name: "block_input",
                      enabled: enabled);
                  setState(() {
                    client.blockInput = enabled;
                  });
                },
              ),
            if (bind.mainSupportedPrivacyModeImpls() != '[]')
              _buildPermissionItem(
                enabled: client.privacyMode,
                iconData: Icons.visibility_off_outlined,
                label: 'PRIVACY',
                tooltipText: translate('Enable privacy mode'),
                canModify: canModifyPermission,
                onTap: (enabled) {
                  bind.cmSwitchPermission(
                      connId: client.id,
                      name: "privacy_mode",
                      enabled: enabled);
                  setState(() {
                    client.privacyMode = enabled;
                  });
                },
              ),
          ];

    final List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 4) {
      final chunk = items.sublist(i, min(i + 4, items.length));
      rows.add(
        Row(
          children: [
            for (final it in chunk)
              Expanded(
                child: Center(child: it),
              ),
            for (int pad = 0; pad < 4 - chunk.length; pad++)
              const Expanded(
                child: SizedBox(),
              ),
          ],
        ),
      );
      if (i + 4 < items.length) {
        rows.add(const SizedBox(height: 12.0));
      }
    }

    return CyberFrame(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CyberLabel(
            '// PERMISSIONS',
            color: Color(0xFF00E5FF),
            fontSize: 9.0,
            letterSpacing: 2.2,
          ),
          const SizedBox(height: 10.0),
          ...rows,
        ],
      ),
    );
  }
}

const double buttonBottomMargin = 8;

class _CmControlPanel extends StatelessWidget {
  final Client client;

  const _CmControlPanel({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return client.authorized
        ? client.disconnected
            ? buildDisconnected(context)
            : buildAuthorized(context)
        : buildUnAuthorized(context);
  }

  buildAuthorized(BuildContext context) {
    final bool canElevate = bind.cmCanElevate();
    final model = Provider.of<ServerModel>(context);
    final showElevation = canElevate &&
        model.showElevation &&
        client.type_() == ClientType.remote;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Offstage(
          offstage: !client.inVoiceCall,
          child: Row(
            children: [
              Expanded(
                child: buildButton(context,
                    color: MyTheme.accent,
                    onClick: null, onTapDown: (details) async {
                  final devicesInfo =
                      await AudioInput.getDevicesInfo(true, true);
                  List<String> devices =
                      devicesInfo['devices'] as List<String>;
                  if (devices.isEmpty) {
                    msgBox(
                      gFFI.sessionId,
                      'custom-nocancel-info',
                      'Prompt',
                      'no_audio_input_device_tip',
                      '',
                      gFFI.dialogManager,
                    );
                    return;
                  }

                  String currentDevice = devicesInfo['current'] as String;
                  final x = details.globalPosition.dx;
                  final y = details.globalPosition.dy;
                  final position = RelativeRect.fromLTRB(x, y, x, y);
                  showMenu(
                    context: context,
                    position: position,
                    items: devices
                        .map((d) => PopupMenuItem<String>(
                              value: d,
                              height: 18,
                              padding: EdgeInsets.zero,
                              onTap: () =>
                                  AudioInput.setDevice(d, true, true),
                              child: IgnorePointer(
                                  child: RadioMenuButton(
                                value: d,
                                groupValue: currentDevice,
                                onChanged: (v) {
                                  if (v != null) {
                                    AudioInput.setDevice(v, true, true);
                                  }
                                },
                                child: Container(
                                  child: Text(
                                    d,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          kConnectionManagerWindowSizeClosedChat
                                                  .width -
                                              80),
                                ),
                              )),
                            ))
                        .toList(),
                  );
                },
                    icon: const Icon(
                      Icons.call_rounded,
                      size: 14,
                    ),
                    text: "Audio input"),
              ),
              Expanded(
                child: buildButton(
                  context,
                  color: Colors.red,
                  onClick: () => closeVoiceCall(),
                  icon: const Icon(
                    Icons.call_end_rounded,
                    size: 14,
                  ),
                  text: "Stop voice call",
                  danger: true,
                ),
              )
            ],
          ),
        ),
        Offstage(
          offstage: !client.incomingVoiceCall,
          child: Row(
            children: [
              Expanded(
                child: buildButton(context,
                    color: MyTheme.accent,
                    onClick: () => handleVoiceCall(true),
                    icon: const Icon(
                      Icons.call_rounded,
                      size: 14,
                    ),
                    text: "Accept"),
              ),
              Expanded(
                child: buildButton(
                  context,
                  color: Colors.red,
                  onClick: () => handleVoiceCall(false),
                  icon: const Icon(
                    Icons.phone_disabled_rounded,
                    size: 14,
                  ),
                  text: "Dismiss",
                  danger: true,
                ),
              )
            ],
          ),
        ),
        Offstage(
          offstage: !client.fromSwitch,
          child: buildButton(context,
              color: Colors.purple,
              onClick: () => handleSwitchBack(context),
              icon: const Icon(Icons.reply, size: 14),
              text: "Switch Sides"),
        ),
        Offstage(
          offstage: !showElevation,
          child: buildButton(
            context,
            color: MyTheme.accent,
            onClick: () {
              handleElevate(context);
              windowManager.minimize();
            },
            icon: const Icon(
              Icons.security_rounded,
              size: 14,
            ),
            text: 'Elevate',
          ),
        ),
        Row(
          children: [
            Expanded(
              child: buildButton(
                context,
                color: Colors.redAccent,
                onClick: handleDisconnect,
                text: 'Disconnect',
                danger: true,
              ),
            ),
          ],
        )
      ],
    ).marginOnly(bottom: buttonBottomMargin);
  }

  buildDisconnected(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: buildButton(
            context,
            color: MyTheme.accent,
            onClick: handleClose,
            text: 'Close',
          ),
        ),
      ],
    ).marginOnly(bottom: buttonBottomMargin);
  }

  buildUnAuthorized(BuildContext context) {
    final bool canElevate = bind.cmCanElevate();
    final model = Provider.of<ServerModel>(context);
    final showElevation = canElevate &&
        model.showElevation &&
        client.type_() == ClientType.remote &&
        bind.mainGetBuildinOption(
                key: kOptionHideElevateButtonInAcceptWindow) !=
            'Y';
    final showAccept = model.approveMode != 'password';
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Offstage(
          offstage: !showElevation || !showAccept,
          child: buildButton(context, color: Colors.green[700], onClick: () {
            handleAccept(context);
            handleElevate(context);
            windowManager.minimize();
          },
              text: 'Accept and Elevate',
              icon: const Icon(
                Icons.security_rounded,
                size: 14,
              ),
              tooltip: 'accept_and_elevate_btn_tooltip'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showAccept)
              Expanded(
                child: Column(
                  children: [
                    buildButton(
                      context,
                      color: MyTheme.accent,
                      onClick: () {
                        handleAccept(context);
                        windowManager.minimize();
                      },
                      text: 'Accept',
                    ),
                  ],
                ),
              ),
            Expanded(
              child: buildButton(
                context,
                color: Colors.transparent,
                border: Border.all(color: Colors.grey),
                onClick: handleDisconnect,
                text: 'Cancel',
              ),
            ),
          ],
        ),
      ],
    ).marginOnly(bottom: buttonBottomMargin);
  }

  Widget buildButton(
    BuildContext context, {
    Color? color,
    GestureTapCallback? onClick,
    Widget? icon,
    BoxBorder? border,
    required String text,
    Color? textColor,
    String? tooltip,
    GestureTapDownCallback? onTapDown,
    bool danger = false,
  }) {
    assert(!(onClick == null && onTapDown == null));

    final isDanger = danger ||
        text == 'Disconnect' ||
        color == Colors.red ||
        color == Colors.redAccent;
    final isCancel = text == 'Cancel' || color == Colors.transparent;
    final isAccept = text == 'Accept' ||
        color == MyTheme.accent;
    final isAcceptAndElevate = text == 'Accept and Elevate' ||
        color == Colors.green ||
        color == Colors.green[700];

    final Color effectiveBorder;
    final Color effectiveBg;
    final Color effectiveText;

    if (isDanger) {
      effectiveBorder = const Color(0xFFFF3B5C);
      effectiveBg = const Color(0x14FF3B5C);
      effectiveText = const Color(0xFFFF3B5C);
    } else if (isCancel) {
      effectiveBorder = const Color(0xFF12303A);
      effectiveBg = Colors.transparent;
      effectiveText = const Color(0xFF5C7A86);
    } else if (isAcceptAndElevate) {
      effectiveBorder = const Color(0xFF00FF9F);
      effectiveBg = const Color(0x1400FF9F);
      effectiveText = const Color(0xFF00FF9F);
    } else if (isAccept) {
      effectiveBorder = const Color(0xFF00E5FF);
      effectiveBg = const Color(0x1F00E5FF);
      effectiveText = const Color(0xFF00E5FF);
    } else {
      effectiveBorder = color ?? const Color(0xFF00E5FF);
      effectiveBg = (color ?? const Color(0xFF00E5FF)).withOpacity(0.12);
      effectiveText = textColor ?? const Color(0xFFCFF8FF);
    }

    final displayText = text == 'Disconnect'
        ? 'TERMINATE LINK'
        : translate(text).toUpperCase();

    final effectiveIcon = text == 'Disconnect'
        ? const Icon(
            Icons.power_settings_new,
            size: 15.0,
            color: Color(0xFFFF3B5C),
          )
        : (icon != null
            ? IconTheme(
                data: IconThemeData(
                  color: effectiveText,
                  size: 14.0,
                ),
                child: icon,
              )
            : null);

    return CyberCutButton(
      text: displayText,
      icon: effectiveIcon,
      color: effectiveBg,
      borderColor: effectiveBorder,
      textColor: effectiveText,
      letterSpacing: text == 'Disconnect' ? 3.0 : 2.0,
      fontSize: text == 'Disconnect' ? 12.0 : 11.0,
      height: text == 'Disconnect' ? 40.0 : 34.0,
      width: double.infinity,
      tooltip: tooltip != null ? translate(tooltip) : null,
      onTap: onClick != null
          ? () => checkClickTime(client.id, onClick)
          : null,
      onTapDown: onTapDown != null
          ? (details) => checkClickTime(client.id, () => onTapDown(details))
          : null,
    ).marginAll(3.0);
  }

  void handleDisconnect() {
    bind.cmCloseConnection(connId: client.id);
  }

  void handleAccept(BuildContext context) {
    final model = Provider.of<ServerModel>(context, listen: false);
    model.sendLoginResponse(client, true);
  }

  void handleElevate(BuildContext context) {
    final model = Provider.of<ServerModel>(context, listen: false);
    model.setShowElevation(false);
    bind.cmElevatePortable(connId: client.id);
  }

  void handleClose() async {
    await bind.cmRemoveDisconnectedConnection(connId: client.id);
    if (await bind.cmGetClientsLength() == 0) {
      windowManager.close();
    }
  }

  void handleSwitchBack(BuildContext context) {
    bind.cmSwitchBack(connId: client.id);
  }

  void handleVoiceCall(bool accept) {
    bind.cmHandleIncomingVoiceCall(id: client.id, accept: accept);
  }

  void closeVoiceCall() {
    bind.cmCloseVoiceCall(id: client.id);
  }
}

void checkClickTime(int id, Function() callback) async {
  if (allowRemoteCMModification()) {
    callback();
    return;
  }
  var clickCallbackTime = DateTime.now().millisecondsSinceEpoch;
  await bind.cmCheckClickTime(connId: id);
  Timer(const Duration(milliseconds: 120), () async {
    var d = clickCallbackTime - await bind.cmGetClickTime();
    if (d > 120) callback();
  });
}

bool allowRemoteCMModification() {
  return option2bool(kOptionAllowRemoteCmModification,
      bind.mainGetLocalOption(key: kOptionAllowRemoteCmModification));
}

class _FileTransferLogPage extends StatefulWidget {
  _FileTransferLogPage({Key? key}) : super(key: key);

  @override
  State<_FileTransferLogPage> createState() => __FileTransferLogPageState();
}

class __FileTransferLogPageState extends State<_FileTransferLogPage> {
  @override
  Widget build(BuildContext context) {
    return statusList();
  }

  Widget generateCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: child,
    );
  }

  iconLabel(CmFileLog item) {
    switch (item.action) {
      case CmFileAction.none:
        return Container();
      case CmFileAction.localToRemote:
      case CmFileAction.remoteToLocal:
        return Column(
          children: [
            Transform.rotate(
              angle: item.action == CmFileAction.remoteToLocal ? 0 : pi,
              child: SvgPicture.asset(
                "assets/arrow.svg",
                colorFilter: svgColor(Theme.of(context).tabBarTheme.labelColor),
              ),
            ),
            Text(item.action == CmFileAction.remoteToLocal
                ? translate('Send')
                : translate('Receive'))
          ],
        );
      case CmFileAction.remove:
        return Column(
          children: [
            Icon(
              Icons.delete,
              color: Theme.of(context).tabBarTheme.labelColor,
            ),
            Text(translate('Delete'))
          ],
        );
      case CmFileAction.createDir:
        return Column(
          children: [
            Icon(
              Icons.create_new_folder,
              color: Theme.of(context).tabBarTheme.labelColor,
            ),
            Text(translate('Create Folder'))
          ],
        );
      case CmFileAction.rename:
        return Column(
          children: [
            Icon(
              Icons.drive_file_move_outlined,
              color: Theme.of(context).tabBarTheme.labelColor,
            ),
            Text(translate('Rename'))
          ],
        );
    }
  }

  Widget statusList() {
    return PreferredSize(
      preferredSize: const Size(200, double.infinity),
      child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Obx(
            () {
              final jobTable = gFFI.cmFileModel.currentJobTable;
              statusListView(List<CmFileLog> jobs) => ListView.builder(
                    controller: ScrollController(),
                    itemBuilder: (BuildContext context, int index) {
                      final item = jobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: generateCard(
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: iconLabel(item),
                                  ).paddingOnly(left: 15),
                                  const SizedBox(
                                    width: 16.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.fileName,
                                        ).paddingSymmetric(vertical: 10),
                                        if (item.totalSize > 0)
                                          Text(
                                            '${translate("Total")} ${readableFileSize(item.totalSize.toDouble())}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: MyTheme.darkGray,
                                            ),
                                          ),
                                        if (item.totalSize > 0)
                                          Offstage(
                                            offstage: item.state !=
                                                JobState.inProgress,
                                            child: Text(
                                              '${translate("Speed")} ${readableFileSize(item.speed)}/s',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: MyTheme.darkGray,
                                              ),
                                            ),
                                          ),
                                        Offstage(
                                          offstage: !(item.isTransfer() &&
                                              item.state !=
                                                  JobState.inProgress),
                                          child: Text(
                                            translate(
                                              item.display(),
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: MyTheme.darkGray,
                                            ),
                                          ),
                                        ),
                                        if (item.totalSize > 0)
                                          Offstage(
                                            offstage: item.state !=
                                                JobState.inProgress,
                                            child: LinearPercentIndicator(
                                              padding:
                                                  EdgeInsets.only(right: 15),
                                              animateFromLastPercent: true,
                                              center: Text(
                                                '${(item.finishedSize / item.totalSize * 100).toStringAsFixed(0)}%',
                                              ),
                                              barRadius: Radius.circular(15),
                                              percent: item.finishedSize /
                                                  item.totalSize,
                                              progressColor: MyTheme.accent,
                                              backgroundColor:
                                                  Theme.of(context).hoverColor,
                                              lineHeight:
                                                  kDesktopFileTransferRowHeight,
                                            ).paddingSymmetric(vertical: 15),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [],
                                  ),
                                ],
                              ),
                            ],
                          ).paddingSymmetric(vertical: 10),
                        ),
                      );
                    },
                    itemCount: jobTable.length,
                  );

              return jobTable.isEmpty
                  ? generateCard(
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/transfer.svg",
                              colorFilter: svgColor(
                                  Theme.of(context).tabBarTheme.labelColor),
                              height: 40,
                            ).paddingOnly(bottom: 10),
                            Text(
                              translate("No transfers in progress"),
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(1.20),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).tabBarTheme.labelColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  : statusListView(jobTable);
            },
          )),
    );
  }
}
