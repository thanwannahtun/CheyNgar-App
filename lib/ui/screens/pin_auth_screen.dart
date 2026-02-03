import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth_cubit.dart';
import '../../../core/bloc_utils/bloc_status.dart';
import '../../../core/route_util/route_names.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({super.key});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  late final TextEditingController _pinController;

  // toggle between login and registration
  bool isRegistration = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (isRegistration) {
      context.read<AuthCubit>().register(
        _pinController.text,
        _phoneController.text,
      );
      return;
    }
    context.read<AuthCubit>().login(
      _pinController.text, // using pin as password
      _phoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == BlocStatus.success) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.app,
                (_) => false,
              );
            }
            if (state.status == BlocStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? "Login failed")),
              );
            }
          },
        ),

        BlocListener<AuthCubit, AuthState>(
          listenWhen: (p, c) => p.registerStatus != c.registerStatus,
          listener: (context, state) {
            if (state.registerStatus == BlocStatus.success) {
              setState(() => isRegistration = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Register success\nLogin again!")),
              );
            }
            if (state.registerStatus == BlocStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? "Registration failed")),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),

                        /// Title
                        Text(
                          isRegistration
                              ? "PIN အသစ်သတ်မှတ်ပါ"
                              : "PIN ဖြင့် ဝင်ရောက်ပါ",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// Phone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Phone required" : null,
                        ),

                        const SizedBox(height: 20),

                        /// PIN (System numeric keyboard)
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            counterText: "",
                            labelText: "PIN Code",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.length != 4) {
                              return "4-digit PIN required";
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: 32),

                        /// Button
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final bool isLoading =
                                state.status == BlocStatus.loading ||
                                state.registerStatus == BlocStatus.loading;

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isLoading) ...[
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                    Text(isRegistration ? "Register" : "Login"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isRegistration = !isRegistration;
                      });
                    },
                    child: Text(
                      isRegistration
                          ? "Already have an account? Login"
                          : "Don't have an account? Register",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
