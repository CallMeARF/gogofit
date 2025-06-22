@extends('layouts.app')

@section('content')
<div class="container" style="padding: 0 15px;"> {{-- FIX: Tambahkan padding container --}}
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Reset Password') }}</div>

                <div class="card-body">
                    <form method="POST" action="{{ route('password.update') }}">
                        @csrf

                        <input type="hidden" name="token" value="{{ $token }}">

                        <div class="mb-3"> {{-- FIX: Hapus class row --}}
                            <label for="email" class="col-form-label text-md-end">{{ __('Email Address') }}</label>

                            <div class="col-md-6"> {{-- FIX: Hapus class col-md-6 --}}
                                <input id="email" type="email" class="form-control @error('email') is-invalid @enderror" name="email" value="{{ $email ?? old('email') }}" required autocomplete="email" autofocus readonly>

                                @error('email')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3"> {{-- FIX: Hapus class row --}}
                            <label for="password" class="col-form-label text-md-end">{{ __('Password') }}</label>

                            <div class="col-md-6"> {{-- FIX: Hapus class col-md-6 --}}
                                <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" required autocomplete="new-password" placeholder="{{ __('Enter new password') }}">
                                @error('password')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3"> {{-- FIX: Hapus class row --}}
                            <label for="password-confirm" class="col-form-label text-md-end">{{ __('Confirm Password') }}</label>

                            <div class="col-md-6"> {{-- FIX: Hapus class col-md-6 --}}
                                <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required autocomplete="new-password" placeholder="{{ __('Confirm new password') }}">
                            </div>
                        </div>

                        <div classrow mb-0"> {{-- FIX: Hapus class row --}}
                            <div class="col-md-6 offset-md-4"> {{-- FIX: Hapus class col-md-6 offset-md-4 --}}
                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1.2rem; padding: 0.75rem 1.2rem; font-size: 1.05rem; border-radius: 0.4rem; font-weight: 600;">
                                    {{ __('Reset Password') }}
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection