using AutoMapper;
using WebApplication1.DTOs;
using WebApplication1.Models;

public class MemberProfileAutoMapper : Profile
{
    public MemberProfileAutoMapper()
    {
        // ---------- Entity -> Response ----------
        CreateMap<MemberProfile, MemberProfileResponseDto>()
            .ForMember(dest => dest.UserName,
                opt => opt.MapFrom(src => src.User.UserName))
            .ForMember(dest => dest.BookingsCount,
                opt => opt.MapFrom(src => src.Bookings.Count))
            .ForMember(dest => dest.AttendanceCount,
                opt => opt.MapFrom(src => src.Attendances.Count))
            .ForMember(dest => dest.FeedbacksGivenCount,
                opt => opt.MapFrom(src => src.FeedbacksGiven.Count))
            .ForMember(dest => dest.ProgressRecordsCount,
                opt => opt.MapFrom(src => src.ProgressRecords.Count));

        // ---------- Create DTO -> Entity ----------
        CreateMap<CreateMemberProfileDto, MemberProfile>()
            .ForMember(dest => dest.UserId, opt => opt.Ignore()) // ⭐ مهم
            .ForMember(dest => dest.User, opt => opt.Ignore())
            .ForMember(dest => dest.Bookings, opt => opt.Ignore())
            .ForMember(dest => dest.Attendances, opt => opt.Ignore())
            .ForMember(dest => dest.FeedbacksGiven, opt => opt.Ignore())
            .ForMember(dest => dest.ProgressRecords, opt => opt.Ignore());

        // ---------- Update DTO -> Entity ----------
        CreateMap<UpdateMemberProfileDto, MemberProfile>()
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.User, opt => opt.Ignore());
    }
}
