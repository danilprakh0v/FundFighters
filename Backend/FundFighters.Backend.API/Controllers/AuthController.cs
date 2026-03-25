/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: AuthController.cs
Расположение: FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для аутентификации и управления пользователями.
            Предоставляет эндпоинты регистрации, верификации email и входа.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Application.Features.Auth.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace FundFighters.Backend.API.Controllers;

/// <summary>
/// Контроллер аутентификации для регистрации пользователей, верификации email и входа.
/// Обрабатывает все HTTP запросы, связанные с аутентификацией и управлением учетными записями.
/// 
/// Authentication controller for user registration, email verification, and login.
/// Handles all authentication-related HTTP requests and account management.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IMediator mediator, ILogger<AuthController> logger)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Registers a new player account.
    /// Validates input, creates player, hashes password, and sends verification email.
    /// </summary>
    /// <param name="request">Registration request containing username, email, and password.</param>
    /// <returns>Registration result with player ID and message.</returns>
    [HttpPost("register")]
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new RegisterResponse
            {
                Success = false,
                Message = "Invalid request data."
            });
        }

        var command = new RegisterCommand
        {
            Username = request.Username,
            Email = request.Email,
            Password = request.Password
        };

        var response = await _mediator.Send(command);

        if (!response.Success)
        {
            _logger.LogWarning($"Registration failed for email: {request.Email}");
            _logger.LogWarning($"Failure reason: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"User registered successfully: {request.Email}");
        _logger.LogInformation($"Verification code sent to: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Verifies a player's email using the verification code.
    /// Code is sent to the email during registration.
    /// </summary>
    /// <param name="request">Verification request containing email and verification code.</param>
    /// <returns>Verification result with player ID and message.</returns>
    [HttpPost("verify")]
    [ProducesResponseType(typeof(VerifyEmailResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(VerifyEmailResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Verify([FromBody] VerifyRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new VerifyEmailResponse
            {
                Success = false,
                Message = "Invalid request data."
            });
        }

        var command = new VerifyEmailCommand
        {
            Email = request.Email,
            Code = request.Code
        };

        var response = await _mediator.Send(command);

        if (!response.Success)
        {
            _logger.LogWarning($"Email verification failed for: {request.Email}. Reason: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Email verified successfully: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Authenticates a player with email and password.
    /// Returns player ID if credentials are valid and email is verified.
    /// </summary>
    /// <param name="request">Login request containing email and password.</param>
    /// <returns>Login result with player ID and message.</returns>
    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return Unauthorized(new LoginResponse
            {
                Success = false,
                Message = "Invalid request data."
            });
        }

        var query = new LoginQuery
        {
            Email = request.Email,
            Password = request.Password
        };

        var response = await _mediator.Send(query);

        if (!response.Success)
        {
            _logger.LogWarning($"Login failed for email: {request.Email}. Reason: {response.Message}");
            return Unauthorized(response);
        }

        _logger.LogInformation($"User logged in successfully: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Verifies the two-factor authentication code for login.
    /// Completes the login process after 2FA code verification.
    /// </summary>
    /// <param name="request">Verification request containing email and 2FA code.</param>
    /// <returns>Verification result with player ID and message.</returns>
    [HttpPost("verify-login")]
    [ProducesResponseType(typeof(VerifyLoginCodeResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(VerifyLoginCodeResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> VerifyLoginCode([FromBody] VerifyLoginCodeRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new VerifyLoginCodeResponse
            {
                Success = false,
                Message = "Invalid request data."
            });
        }

        var query = new VerifyLoginCodeQuery
        {
            Email = request.Email,
            Code = request.Code
        };

        var response = await _mediator.Send(query);

        if (!response.Success)
        {
            _logger.LogWarning($"Login code verification failed for: {request.Email}. Reason: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Login code verified successfully: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Инициирует процесс сброса пароля. Отправляет код подтверждения на email.
    /// Initiates password reset process. Sends confirmation code to email.
    /// </summary>
    /// <param name="request">Request containing user email.</param>
    [HttpPost("forgot-password")]
    [ProducesResponseType(typeof(ForgotPasswordResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ForgotPasswordResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        if (!ModelState.IsValid || string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new ForgotPasswordResponse
            {
                Success = false,
                Message = "Email is required."
            });
        }

        var command = new ForgotPasswordCommand { Email = request.Email };
        var response = await _mediator.Send(command);

        if (!response.Success)
        {
            _logger.LogWarning($"Forgot password request failed for: {request.Email}. Reason: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Forgot password code sent to: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Завершает сброс пароля, проверяя код и устанавливая новый пароль.
    /// Completes password reset by verifying code and setting new password.
    /// </summary>
    /// <param name="request">Request containing email, code and new password.</param>
    [HttpPost("reset-password")]
    [ProducesResponseType(typeof(ResetPasswordResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ResetPasswordResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new ResetPasswordResponse
            {
                Success = false,
                Message = "Invalid request data."
            });
        }

        var command = new ResetPasswordCommand
        {
            Email = request.Email,
            Code = request.Code,
            NewPassword = request.NewPassword
        };

        var response = await _mediator.Send(command);

        if (!response.Success)
        {
            _logger.LogWarning($"Password reset failed for: {request.Email}. Reason: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Password reset successfully for: {request.Email}");
        return Ok(response);
    }
}



/// <summary>
/// Модель запроса для регистрации пользователя.
/// Request model for user registration.
/// </summary>
public class RegisterRequest
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Модель запроса для входа пользователя в систему.
/// Request model for user login.
/// </summary>
public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Модель запроса для верификации email адреса.
/// Request model for email verification.
/// </summary>
public class VerifyRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Модель запроса для верификации кода двухфакторной аутентификации при входе.
/// Request model for verifying two-factor authentication code during login.
/// </summary>
public class VerifyLoginCodeRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Модель запроса для верификации email адреса.
/// Request model for email verification.
/// </summary>
public class ForgotPasswordRequest
{
    public string Email { get; set; } = string.Empty;
}

/// <summary>
/// Модель запроса для завершения сброса пароля.
/// Request model for password reset completion.
/// </summary>
public class ResetPasswordRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}
