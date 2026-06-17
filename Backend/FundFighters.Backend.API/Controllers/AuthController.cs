/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: AuthController.cs
Расположение: Backend/FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для аутентификации и управления пользователями.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Application.Features.Auth.Queries;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FundFighters.Backend.API.Controllers;

/// <summary>
/// Контроллер аутентификации: регистрация, верификация email и вход в систему.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<AuthController> _logger;
    private readonly IGameRepository _repository;

    public AuthController(IMediator mediator, ILogger<AuthController> logger, IGameRepository repository)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    /// <summary>
    /// Регистрация нового игрового аккаунта.
    /// </summary>
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
                Message = "Некорректные данные запроса."
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
            _logger.LogWarning($"Ошибка регистрации для: {request.Email}. Причина: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Пользователь успешно зарегистрирован: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Верификация email с помощью кода подтверждения.
    /// </summary>
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
                Message = "Некорректные данные запроса."
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
            _logger.LogWarning($"Ошибка верификации email для: {request.Email}. Причина: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Email успешно верифицирован: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Аутентификация пользователя (вход).
    /// </summary>
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
                Message = "Некорректные данные запроса."
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
            _logger.LogWarning($"Ошибка входа для: {request.Email}. Причина: {response.Message}");
            return Unauthorized(response);
        }

        _logger.LogInformation($"Пользователь успешно вошел в систему: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Проверка кода двухфакторной аутентификации.
    /// </summary>
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
                Message = "Некорректные данные запроса."
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
            _logger.LogWarning($"Ошибка проверки кода входа для: {request.Email}. Причина: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Код входа успешно подтвержден: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Инициация процесса восстановления пароля.
    /// </summary>
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
                Message = "Email обязателен для заполнения."
            });
        }

        var command = new ForgotPasswordCommand { Email = request.Email };
        var response = await _mediator.Send(command);

        if (!response.Success)
        {
            _logger.LogWarning($"Ошибка запроса восстановления пароля для: {request.Email}. Причина: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Код восстановления пароля отправлен на: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Завершение процесса сброса пароля.
    /// </summary>
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
                Message = "Некорректные данные запроса."
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
            _logger.LogWarning($"Ошибка сброса пароля для: {request.Email}. Причина: {response.Message}");
            return BadRequest(response);
        }

        _logger.LogInformation($"Пароль успешно изменен для: {request.Email}");
        return Ok(response);
    }

    /// <summary>
    /// Переключение двухфакторной аутентификации для текущего пользователя.
    /// </summary>
    [Authorize]
    [HttpPut("two-factor")]
    [ProducesResponseType(typeof(TwoFactorStatusResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateTwoFactor([FromBody] UpdateTwoFactorRequest request)
    {
        var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(playerId))
        {
            return Unauthorized(new { message = "Ошибка идентификации пользователя." });
        }

        var player = await _repository.GetPlayerByIdAsync(playerId);
        if (player is null)
        {
            return NotFound(new { message = "Пользователь не найден." });
        }

        player.IsTwoFactorEnabled = request.Enabled;
        await _repository.SaveChangesAsync();

        _logger.LogInformation($"2FA updated for player {playerId}: {request.Enabled}");
        return Ok(new TwoFactorStatusResponse
        {
            IsTwoFactorEnabled = player.IsTwoFactorEnabled
        });
    }

    /// <summary>
    /// Обновление профиля текущего пользователя.
    /// </summary>
    [Authorize]
    [HttpPut("profile")]
    [ProducesResponseType(typeof(ProfileResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(playerId))
        {
            return Unauthorized(new { message = "Ошибка идентификации пользователя." });
        }

        var username = request?.Username?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(username) || username.Length > 32)
        {
            return BadRequest(new { message = "Имя должно содержать от 1 до 32 символов." });
        }

        var player = await _repository.GetPlayerByIdAsync(playerId);
        if (player is null)
        {
            return NotFound(new { message = "Пользователь не найден." });
        }

        player.Username = username;
        player.UpdatedAt = DateTime.UtcNow;
        await _repository.SaveChangesAsync();

        _logger.LogInformation($"Profile updated for player {playerId}");
        return Ok(new ProfileResponse
        {
            Username = player.Username,
            Email = player.Email,
            PlayerId = player.Id,
            IsTwoFactorEnabled = player.IsTwoFactorEnabled
        });
    }
}

/// <summary>
/// Запрос на регистрацию пользователя.
/// </summary>
public class RegisterRequest
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на вход в систему.
/// </summary>
public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на верификацию email.
/// </summary>
public class VerifyRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на подтверждение кода 2FA.
/// </summary>
public class VerifyLoginCodeRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на восстановление пароля.
/// </summary>
public class ForgotPasswordRequest
{
    public string Email { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на установку нового пароля.
/// </summary>
public class ResetPasswordRequest
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

/// <summary>
/// Запрос на переключение двухфакторной аутентификации.
/// </summary>
public class UpdateTwoFactorRequest
{
    public bool Enabled { get; set; }
}

/// <summary>
/// Текущее состояние двухфакторной аутентификации.
/// </summary>
public class TwoFactorStatusResponse
{
    public bool IsTwoFactorEnabled { get; set; }
}

/// <summary>
/// Запрос на обновление профиля.
/// </summary>
public class UpdateProfileRequest
{
    public string Username { get; set; } = string.Empty;
}

/// <summary>
/// Актуальное состояние профиля после сохранения.
/// </summary>
public class ProfileResponse
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int PlayerId { get; set; }
    public bool IsTwoFactorEnabled { get; set; }
}
